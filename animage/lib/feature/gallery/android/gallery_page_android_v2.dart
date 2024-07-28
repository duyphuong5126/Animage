import 'package:animage/constant.dart';
import 'package:animage/feature/gallery/gallery_cubit.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/gallery_grid_item_android.dart';
import 'package:animage/widget/gallery_list_item_android.dart';
import 'package:animage/widget/gallery_mode_switch.dart';
import 'package:animage/widget/loading_body.dart';
import 'package:animage/widget/loading_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../service/ad_service.dart';
import '../../ui_model/gallery_mode.dart';
import '../gallery_page_state.dart';

class GalleryPageAndroidV2 extends StatelessWidget {
  const GalleryPageAndroidV2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => GalleryCubit()..loadMore(),
      child: BlocBuilder<GalleryCubit, GalleryPageState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: const _SearchView(),
              ),
              actions: [
                if (state is GalleryPageInitializedState)
                  GalleryModeSwitch(
                    onModeSelected:
                        context.read<GalleryCubit>().changeGalleryMode,
                    galleryMode: state.galleryMode,
                  ),
              ],
            ),
            body: switch (state) {
              GalleryPageInitialState() => const LoadingBody(),
              GalleryPageInitializedState() => _InitializedBody(
                  state: state,
                  prefetchDistance: screenHeight,
                  loadMore: () => context.read<GalleryCubit>().loadMore(),
                ),
            },
          );
        },
      ),
    );
  }
}

class _InitializedBody extends StatefulWidget {
  const _InitializedBody({
    required this.state,
    required this.prefetchDistance,
    required this.loadMore,
  });

  final GalleryPageInitializedState state;
  final double prefetchDistance;
  final Function() loadMore;

  @override
  State<_InitializedBody> createState() => _InitializedBodyState();
}

class _InitializedBodyState extends State<_InitializedBody> {
  final ScrollController _scrollController = ScrollController();
  late BannerAd _bannerAd;
  bool _isAdReady = false;
  bool _showTransitionLoading = false;

  RewardedAd? _firstRewardedAd;
  RewardedAd? _secondRewardedAd;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          logE('Failed to load a banner ad: ${err.message}', error: err);
          setState(() {
            _isAdReady = false;
          });
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();

    context.read<GalleryCubit>().requestLevelChallenge();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GalleryCubit, GalleryPageState>(
      listener: (context, state) {
        if (state is Initialized && state.galleryLevelChanged) {
          _loadRewardedAd(context, state.galleryLevel);
        }
      },
      child: Stack(
        children: [
          switch (widget.state.galleryMode) {
            GalleryMode.list => _list(context),
            GalleryMode.grid => _grid(context),
          },
          if (_isAdReady)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints.expand(
                    width: double.infinity,
                    height: _bannerAd.size.height.toDouble(),
                  ),
                  color: context.defaultBackgroundColor,
                  child: SizedBox(
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ),
                ),
              ),
            ),
          if (_showTransitionLoading)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  color: defaultTransparentGrey,
                  child: Center(
                    child: SizedBox(
                      width: space2,
                      height: space2,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: widget.state.postList.length + 1,
      padding: const EdgeInsets.symmetric(horizontal: halfSpace),
      separatorBuilder: (context, index) {
        return const SizedBox(height: halfSpace);
      },
      itemBuilder: (context, index) {
        if (index == widget.state.postList.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: space3),
            child: LoadingRow(),
          );
        }
        final item = widget.state.postList[index];
        return GalleryListItemAndroid(
          uiModel: item,
          itemAspectRatio: 1.5,
          onOpenDetail: (model) {},
          onCloseDetail: () {},
          onFavoriteChanged: (favorite) =>
              context.read<GalleryCubit>().toggleFavorite(item.post),
          onTagsSelected: (tags) =>
              context.read<GalleryCubit>().addSearchTags(tags),
        );
      },
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }

  Widget _grid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: halfSpace),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = widget.state.postList[index];
                return GalleryGridItemAndroid(
                  uiModel: item,
                  itemAspectRatio: 1.0,
                  onCloseDetail: () {},
                  onFavoriteChanged: (favorite) =>
                      context.read<GalleryCubit>().toggleFavorite(item.post),
                  onTagsSelected: (tags) =>
                      context.read<GalleryCubit>().addSearchTags(tags),
                );
              },
              childCount: widget.state.postList.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: halfSpace,
              crossAxisSpacing: halfSpace,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: space3),
              child: LoadingRow(),
            ),
          ),
        ],
      ),
    );
  }

  _onScroll() {
    ScrollPosition scrollPosition = _scrollController.position;
    double maxScroll = scrollPosition.maxScrollExtent;
    double currentScroll = scrollPosition.pixels;
    if (maxScroll - currentScroll <= widget.prefetchDistance) {
      widget.loadMore();
    }
  }

  void _loadRewardedAd(BuildContext context, int levelId) async {
    if (levelId == 1) {
      _loadLevel1Ad(context);
    } else if (levelId == 2) {
      _loadLevel2Ads(context);
    }
  }

  void _loadLevel1Ad(BuildContext context) {
    final cubit = context.read<GalleryCubit>();
    RewardedAd.load(
      adUnitId: AdService.firstRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          bool isRewardEarned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              if (isRewardEarned) {
                context.showConfirmationDialog(
                  title: 'Offer Earned',
                  message: cubit.specialOfferEarnedMessage(1),
                  actionLabel: 'OK',
                  action: () => cubit.refresh(),
                );
              }
            },
          );

          _firstRewardedAd = ad;

          context.showYesNoDialog(
            title: 'Special Offer',
            content: cubit.specialOfferMessage(1),
            yesLabel: 'Yes',
            yesAction: () => _firstRewardedAd?.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                if (reward.amount.isFinite) {
                  isRewardEarned = true;
                  cubit.enableGalleryLevel(1);
                }
              },
            ),
            noLabel: 'No',
            noAction: () => cubit.hideLevelUpMessageTemporarily(1),
          );
        },
        onAdFailedToLoad: (err) {
          Log.d(
            '_GalleryPageAndroidState',
            'Failed to load a rewarded ad: ${err.message}',
          );
        },
      ),
    );
  }

  void _loadLevel2Ads(BuildContext context) {
    final cubit = context.read<GalleryCubit>();
    RewardedAd.load(
      adUnitId: AdService.firstRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (firstAd) {
          bool isFirstRewardEarned = false;
          firstAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              if (isFirstRewardEarned) {
                RewardedAd.load(
                  adUnitId: AdService.secondRewardedAdId,
                  request: const AdRequest(),
                  rewardedAdLoadCallback: RewardedAdLoadCallback(
                    onAdLoaded: (secondAd) {
                      bool isSecondRewardEarned = false;
                      secondAd.fullScreenContentCallback =
                          FullScreenContentCallback(
                        onAdDismissedFullScreenContent: (ad) {
                          if (isSecondRewardEarned) {
                            context.showConfirmationDialog(
                              title: 'Offer Earned',
                              message: cubit.specialOfferEarnedMessage(2),
                              actionLabel: 'OK',
                              action: () => cubit.refresh(),
                            );
                          }
                        },
                        onAdFailedToShowFullScreenContent: (add, error) {
                          if (_showTransitionLoading) {
                            setState(() {
                              _showTransitionLoading = false;
                            });
                          }
                        },
                        onAdShowedFullScreenContent: (ad) {
                          if (_showTransitionLoading) {
                            setState(() {
                              _showTransitionLoading = false;
                            });
                          }
                        },
                      );

                      _secondRewardedAd = secondAd;

                      _secondRewardedAd?.show(
                        onUserEarnedReward:
                            (AdWithoutView ad, RewardItem reward) {
                          if (reward.amount.isFinite) {
                            isSecondRewardEarned = true;
                            cubit.enableGalleryLevel(2);
                          }
                        },
                      );
                    },
                    onAdFailedToLoad: (err) {
                      Log.d(
                        '_GalleryPageAndroidState',
                        'Failed to load a rewarded ad: ${err.message}',
                      );
                    },
                  ),
                );
              }
            },
          );

          _firstRewardedAd = firstAd;

          context.showYesNoDialog(
            title: 'Special Offer',
            content: cubit.specialOfferMessage(2),
            yesLabel: 'Yes',
            yesAction: () => _firstRewardedAd?.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                if (reward.amount.isFinite) {
                  isFirstRewardEarned = true;
                  if (!_showTransitionLoading) {
                    setState(() {
                      _showTransitionLoading = true;
                    });
                  }
                }
              },
            ),
            noLabel: 'No',
            noAction: () => cubit.hideLevelUpMessageTemporarily(2),
          );
        },
        onAdFailedToLoad: (err) {
          Log.d(
            '_GalleryPageAndroidState',
            'Failed to load a rewarded ad: ${err.message}',
          );
        },
      ),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    Color? searchTextColor =
        context.isDark ? Colors.white : Colors.grey[900]; // todo
    Color? searchHintColor = context.isDark ? Colors.white : Colors.grey[700];

    List<String> history = []; // todo
    return RawAutocomplete<String>(
      optionsBuilder: (TextEditingValue text) {
        String searchTerm = text.text.trim().toLowerCase();
        if (searchTerm.isEmpty) {
          return const [];
        }
        return history.where((historyItem) {
          return historyItem.startsWith(searchTerm);
        });
      },
      onSelected: (historyItem) {
        //todo
      },
      optionsViewBuilder: (context, onSelected, Iterable<String> history) {
        double maxHeight = (context.safeAreaHeight * 2) / 3;
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(halfSpace),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4.0,
                ),
              ],
              color: context.defaultBackgroundColor,
            ),
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, int index) => Divider(
                color: context.defaultDividerColor,
                height: 1,
              ),
              padding: EdgeInsets.zero,
              itemCount: history.length,
              itemBuilder: (context, int index) {
                String historyItem = history.elementAt(index);
                return Container(
                  color: context.defaultBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: space1,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: context.bodyText2,
                              children: [TextSpan(text: historyItem)],
                            ),
                          ),
                          onTap: () => onSelected(historyItem),
                        ),
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: context.secondaryColor,
                          ),
                        ),
                        onTap: () => _removeSearchHistory(historyItem),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        textEditingController.addListener(() {
          /*_showClearSearchButtonCubit
                  .push(textEditingController.text.isNotEmpty);*/ //todo
        });
        return TextField(
          autofocus: false,
          focusNode: focusNode,
          controller: textEditingController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: context.secondaryColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: context.secondaryColor),
              onPressed: () {
                textEditingController.clear();
              },
            ),
            // hintText: _viewModel.searchHint, //todo
            hintStyle: context.bodyText2?.copyWith(
              color: searchHintColor,
              overflow: TextOverflow.ellipsis,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: quarterSpace),
          ),
          onSubmitted: (String searchTerm) {
            textEditingController.clear();
            // todo
          },
        );
      },
    );
  }

  void _removeSearchHistory(String historyItem) {}
}
