import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/gallery/gallery_view_model.dart';
import 'package:animage/feature/gallery/new_posts_cubit.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/ad_service.dart';
import 'package:animage/service/analytics_helper.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/utils/utils.dart';
import 'package:animage/widget/gallery_grid_item_android.dart';
import 'package:animage/widget/gallery_list_item_android.dart';
import 'package:animage/widget/gallery_mode_switch.dart';
import 'package:animage/widget/list_update_notification_android.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GalleryPageAndroid extends StatefulWidget {
  final DataCubit<int> scrollToTopCubit;

  const GalleryPageAndroid({Key? key, required this.scrollToTopCubit})
      : super(key: key);

  @override
  State<GalleryPageAndroid> createState() => _GalleryPageAndroidState();
}

class _GalleryPageAndroidState extends State<GalleryPageAndroid> {
  static const String _tag = '_GalleryPageAndroidState';
  final GalleryViewModel _viewModel = GalleryViewModelImpl();
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);
  final DataCubit<bool> _showTransitionLoadingCubit = DataCubit(false);

  ScrollController? _scrollController;
  StreamSubscription? _scrollToTopSubscription;
  StreamSubscription? _getGallerySubscription;

  late BannerAd _bannerAd;
  bool _isAdReady = false;

  RewardedAd? _firstRewardedAd;
  RewardedAd? _secondRewardedAd;

  ScrollController _getScrollController() {
    if (_scrollController != null) {
      _scrollController?.dispose();
    }
    ScrollController scrollController = ScrollController();
    _scrollController = scrollController;
    return scrollController;
  }

  @override
  void initState() {
    super.initState();
    _viewModel.init();
    _scrollToTopSubscription =
        widget.scrollToTopCubit.stream.listen((int time) {
      if (time > 0) {
        _scrollController?.jumpTo(0);
      }
    });
    _getGallerySubscription =
        getCurrentGalleryMode().asStream().listen((GalleryMode mode) {
      _modeCubit.push(mode);
    });
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
          Log.d(_tag, 'Failed to load a banner ad: ${err.message}');
          setState(() {
            _isAdReady = false;
          });
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();

    _viewModel.requestLevelChallenge();
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.destroy();
    _modeCubit.closeAsync();
    _scrollToTopSubscription?.cancel();
    _scrollToTopSubscription = null;
    _getGallerySubscription?.cancel();
    _getGallerySubscription = null;
    _scrollController?.dispose();
    _scrollController = null;
    _bannerAd.dispose();
    _firstRewardedAd?.dispose();
    _secondRewardedAd?.dispose();
    _showTransitionLoadingCubit.closeAsync();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDark;

    Color? searchBackgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NewPostsCubit()),
      ],
      child: BlocListener(
        bloc: _viewModel.galleryLevelIndexCubit,
        listener: (context, int levelId) {
          _loadRewardedAd(levelId);
        },
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).backgroundColor,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).backgroundColor,
            title: Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: searchBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: _SearchView(viewModel: _viewModel),
            ),
            scrolledUnderElevation: 0.0,
          ),
          body: BlocBuilder(
            bloc: _showTransitionLoadingCubit,
            builder: (context, bool showTransitionLoading) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: halfSpace),
                    child: BlocBuilder(
                      bloc: _modeCubit,
                      builder: (context, GalleryMode mode) {
                        return BlocConsumer(
                          listener: (context, List<String> tags) {
                            context.read<NewPostsCubit>().updateTagsList(tags);
                          },
                          bloc: _viewModel.tagListCubit,
                          builder: (context, List<String> tags) {
                            bool hasTag = tags.isNotEmpty;
                            List<Widget> bodyWidgets = [
                              _MainBody(
                                viewModel: _viewModel,
                                modeCubit: _modeCubit,
                                scrollController: _getScrollController(),
                                isAdReady: _isAdReady,
                                hasTag: hasTag,
                                galleryMode: mode,
                                tags: tags,
                              ),
                              if (_isAdReady)
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      constraints: BoxConstraints.expand(
                                        width: double.infinity,
                                        height:
                                            _bannerAd.size.height.toDouble(),
                                      ),
                                      color: context.defaultBackgroundColor,
                                      child: SizedBox(
                                        width: _bannerAd.size.width.toDouble(),
                                        height:
                                            _bannerAd.size.height.toDouble(),
                                        child: AdWidget(ad: _bannerAd),
                                      ),
                                    ),
                                  ),
                                ),
                            ];
                            return Stack(children: bodyWidgets);
                          },
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: showTransitionLoading,
                    child: Container(
                      color: defaultTransparentGrey,
                      child: Center(
                        child: SizedBox(
                          width: x2Space,
                          height: x2Space,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
      ),
    );
  }

  void _loadRewardedAd(int levelId) async {
    if (levelId == 1) {
      _loadLevel1Ad();
    } else if (levelId == 2) {
      _loadLevel2Ads();
    }
  }

  void _loadLevel1Ad() {
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
                  title: _viewModel.specialOfferEarnedTitle,
                  message: _viewModel.specialOfferEarnedMessage(
                    _viewModel.galleryLevelIndexCubit.state,
                  ),
                  actionLabel: _viewModel.specialOfferEarnedConfirmLabel,
                  action: () => _viewModel.refreshGallery(),
                );
              }
            },
          );

          _firstRewardedAd = ad;

          context.showYesNoDialog(
            title: _viewModel.specialOfferTitle,
            content: _viewModel.specialOfferMessage(1),
            yesLabel: _viewModel.specialOfferAcceptLabel,
            yesAction: () => _firstRewardedAd?.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                if (reward.amount.isFinite) {
                  isRewardEarned = true;
                  _viewModel.enableGalleryLevel(1);
                }
              },
            ),
            noLabel: _viewModel.specialOfferDenyLabel,
            noAction: () => _viewModel.hideLevelUpMessageTemporarily(1),
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

  void _loadLevel2Ads() {
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
                              title: _viewModel.specialOfferEarnedTitle,
                              message: _viewModel.specialOfferEarnedMessage(
                                _viewModel.galleryLevelIndexCubit.state,
                              ),
                              actionLabel:
                                  _viewModel.specialOfferEarnedConfirmLabel,
                              action: () => _viewModel.refreshGallery(),
                            );
                          }
                        },
                        onAdFailedToShowFullScreenContent: (add, error) {
                          _showTransitionLoadingCubit.push(false);
                        },
                        onAdShowedFullScreenContent: (ad) {
                          _showTransitionLoadingCubit.push(false);
                        },
                      );

                      _secondRewardedAd = secondAd;

                      _secondRewardedAd?.show(
                        onUserEarnedReward:
                            (AdWithoutView ad, RewardItem reward) {
                          if (reward.amount.isFinite) {
                            isSecondRewardEarned = true;
                            _viewModel.enableGalleryLevel(2);
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
            title: _viewModel.specialOfferTitle,
            content: _viewModel.specialOfferMessage(2),
            yesLabel: _viewModel.specialOfferAcceptLabel,
            yesAction: () => _firstRewardedAd?.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                if (reward.amount.isFinite) {
                  isFirstRewardEarned = true;
                  _showTransitionLoadingCubit.push(true);
                }
              },
            ),
            noLabel: _viewModel.specialOfferDenyLabel,
            noAction: () => _viewModel.hideLevelUpMessageTemporarily(2),
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

class _MainBody extends StatefulWidget {
  const _MainBody({
    required this.viewModel,
    required this.modeCubit,
    required this.scrollController,
    required this.isAdReady,
    required this.hasTag,
    required this.galleryMode,
    required this.tags,
  });

  final GalleryViewModel viewModel;
  final ScrollController scrollController;
  final bool isAdReady;
  final bool hasTag;
  final GalleryMode galleryMode;
  final DataCubit<GalleryMode> modeCubit;
  final List<String> tags;

  @override
  State<_MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<_MainBody> {
  bool _headerVisible = true;

  ScrollDirection? lastScrollDirection;

  _onScrollDirectionChanged(ScrollDirection scrollDirection) async {
    if (scrollDirection != lastScrollDirection) {
      lastScrollDirection = scrollDirection;
      if (scrollDirection == ScrollDirection.reverse) {
        setState(() {
          _headerVisible = false;
        });
      } else if (scrollDirection == ScrollDirection.forward) {
        setState(() {
          _headerVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: _GalleryBody(
              viewModel: widget.viewModel,
              scrollController: widget.scrollController,
              isAdReady: widget.isAdReady,
              hasTag: widget.hasTag,
              galleryMode: widget.galleryMode,
              onScrollDirectionChanged: _onScrollDirectionChanged,
              headerVisible: _headerVisible,
            ),
          ),
        ),
        if (_headerVisible)
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: _GalleryHeader(
                viewModel: widget.viewModel,
                modeCubit: widget.modeCubit,
                galleryMode: widget.galleryMode,
                tags: widget.tags,
              ),
            ),
          ),
      ],
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const _GalleryBody({
    required this.viewModel,
    required this.scrollController,
    required this.isAdReady,
    required this.hasTag,
    required this.headerVisible,
    required this.galleryMode,
    required this.onScrollDirectionChanged,
  });

  final GalleryViewModel viewModel;
  final ScrollController scrollController;
  final bool isAdReady;
  final bool hasTag;
  final bool headerVisible;
  final GalleryMode galleryMode;

  final Function(ScrollDirection) onScrollDirectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: headerVisible ? x3Space + (hasTag ? x3Space : 0) : 0.0,
      ),
      child: BlocBuilder(
        bloc: viewModel.setUpFinishCubit,
        builder: (
          context,
          bool setUpFinished,
        ) {
          return setUpFinished
              ? _initializedBody()
              : _loadingWidget(context.secondaryColor);
        },
      ),
    );
  }

  Widget _initializedBody() {
    final gallery = galleryMode == GalleryMode.grid
        ? _PagedGridView(
            viewModel: viewModel,
            scrollController: scrollController,
            isAdReady: isAdReady,
          )
        : _PagedListView(
            viewModel: viewModel,
            scrollController: scrollController,
            isAdReady: isAdReady,
          );
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        RefreshIndicator(
          onRefresh: () => Future.sync(() => viewModel.refreshGallery()),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              onScrollDirectionChanged(notification.direction);
              return true;
            },
            child: gallery,
          ),
        ),
        _NewPostsArea(viewModel: viewModel),
      ],
    );
  }

  Widget _loadingWidget(Color color) {
    return Center(
      child: SizedBox(
        width: x2Space,
        height: x2Space,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

class _PagedGridView extends StatelessWidget {
  const _PagedGridView({
    required this.scrollController,
    required this.viewModel,
    required this.isAdReady,
  });

  final GalleryViewModel viewModel;
  final ScrollController scrollController;
  final bool isAdReady;

  GalleryViewModel get _viewModel => viewModel;

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, PostCardUiModel>(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      scrollController: scrollController,
      pagingController: _viewModel.getPagingController(),
      builderDelegate: PagedChildBuilderDelegate(
        firstPageProgressIndicatorBuilder: (context) =>
            _LoadingWidget(context.secondaryColor),
        newPageProgressIndicatorBuilder: (context) => Container(
          padding: EdgeInsets.only(
            bottom: isAdReady ? AdSize.banner.height.toDouble() : 0,
          ),
          child: _LoadingWidget(context.secondaryColor),
        ),
        itemBuilder: (context, postItem, index) {
          if (index == 0) {
            context.read<NewPostsCubit>().init(postItem.id);
          }
          return GalleryGridItemAndroid(
            uiModel: postItem,
            itemAspectRatio: 1.0,
            postDetailsCubit: _viewModel.postDetailsCubit,
            onOpenDetail: (postUiModel) {
              _viewModel.requestDetailsPage(postUiModel.id);
            },
            onCloseDetail: () => _viewModel.clearDetailsPageRequest(),
            onFavoriteChanged: (postUiModel) =>
                _viewModel.toggleFavorite(postUiModel),
            onTagsSelected: _viewModel.addSearchTags,
          );
        },
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1.0,
        crossAxisCount: 2,
        mainAxisSpacing: halfSpace,
        crossAxisSpacing: halfSpace,
      ),
    );
  }
}

class _PagedListView extends StatelessWidget {
  const _PagedListView({
    required this.scrollController,
    required this.viewModel,
    required this.isAdReady,
  });

  final GalleryViewModel viewModel;
  final ScrollController scrollController;
  final bool isAdReady;

  GalleryViewModel get _viewModel => viewModel;

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, PostCardUiModel>(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      scrollController: scrollController,
      pagingController: _viewModel.getPagingController(),
      builderDelegate: PagedChildBuilderDelegate<PostCardUiModel>(
        newPageProgressIndicatorBuilder: (context) => Container(
          padding: EdgeInsets.only(
            bottom: isAdReady ? AdSize.banner.height.toDouble() : 0,
          ),
          child: _LoadingWidget(context.secondaryColor),
        ),
        firstPageProgressIndicatorBuilder: (context) =>
            _LoadingWidget(context.secondaryColor),
        firstPageErrorIndicatorBuilder: (context) => Center(
          child: PlatformText(
            _viewModel.firstPageErrorMessage,
            style: context.bodyText1,
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => Center(
          child: PlatformText(
            _viewModel.emptyMessage,
            style: context.bodyText1,
          ),
        ),
        itemBuilder: (context, postItem, index) {
          if (index == 0) {
            context.read<NewPostsCubit>().init(postItem.id);
          }
          return Container(
            margin: const EdgeInsets.only(bottom: halfSpace),
            child: GalleryListItemAndroid(
              uiModel: postItem,
              itemAspectRatio: 1.5,
              postDetailsCubit: _viewModel.postDetailsCubit,
              onOpenDetail: (postUiModel) {
                _viewModel.requestDetailsPage(postUiModel.id);
              },
              onCloseDetail: () => _viewModel.clearDetailsPageRequest(),
              onFavoriteChanged: (postUiModel) =>
                  _viewModel.toggleFavorite(postUiModel),
              onTagsSelected: _viewModel.addSearchTags,
            ),
          );
        },
      ),
    );
  }
}

class _NewPostsArea extends StatefulWidget {
  const _NewPostsArea({required this.viewModel});

  final GalleryViewModel viewModel;

  @override
  State<_NewPostsArea> createState() => _NewPostsAreaState();
}

class _NewPostsAreaState extends State<_NewPostsArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _notificationAnimationController;
  late Animation<Offset> _notificationSlideInAnimation;

  GalleryViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    _notificationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _notificationSlideInAnimation =
        Tween<Offset>(begin: const Offset(0.0, -5.0), end: Offset.zero)
            .animate(_notificationAnimationController);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewPostsCubit, Iterable<String>>(
      listener: (context, Iterable<String> sampleList) {
        if (sampleList.isNotEmpty) {
          _notificationAnimationController.forward();
        }
      },
      builder: (context, Iterable<String> sampleList) {
        return sampleList.isNotEmpty
            ? SlideTransition(
                position: _notificationSlideInAnimation,
                child: Container(
                  margin: const EdgeInsets.only(top: halfSpace),
                  child: GestureDetector(
                    onTap: () {
                      _notificationAnimationController.reverse();
                      context.read<NewPostsCubit>().reset();
                      _viewModel.refreshGallery();
                    },
                    child: ListUpdateNotificationAndroid(
                      message: 'New posts',
                      images: sampleList,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: halfSpace),
        child: SizedBox(
          width: x2Space,
          height: x2Space,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.viewModel,
    required this.modeCubit,
    required this.tags,
    required this.galleryMode,
  });

  final GalleryViewModel viewModel;
  final DataCubit<GalleryMode> modeCubit;
  final GalleryMode galleryMode;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final hasTags = tags.isNotEmpty;
    return Container(
      height: x2Space + normalSpace + (hasTags ? x2Space : 0.0),
      color: context.defaultBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: halfSpace),
                child: Text(
                  viewModel.pageTitle,
                  style: context.headline6,
                ),
              ),
              GalleryModeSwitch(
                onModeSelected: (mode) {
                  modeCubit.push(mode);
                  saveGalleryModePref(mode);
                  switch (mode) {
                    case GalleryMode.list:
                      AnalyticsHelper.viewListGallery();
                      break;
                    case GalleryMode.grid:
                      AnalyticsHelper.viewGridGallery();
                  }
                },
                galleryMode: galleryMode,
              ),
            ],
          ),
          Visibility(
            visible: tags.isNotEmpty,
            child: Container(
              constraints: const BoxConstraints.expand(
                height: x2Space,
              ),
              margin: const EdgeInsets.only(top: halfSpace),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  String tag = tags[index];
                  return Chip(
                    padding: EdgeInsets.zero,
                    side: BorderSide.none,
                    deleteIcon: const Icon(Icons.close),
                    deleteIconColor: Colors.white,
                    onDeleted: () {
                      context.showYesNoDialog(
                        title: viewModel.removeTagTitle,
                        content: viewModel.getTagRemovalMessage(tag),
                        yesLabel: viewModel.acceptTagRemoval,
                        yesAction: () => viewModel.removeSearchTag(tag),
                        noLabel: viewModel.cancelTagRemoval,
                        noAction: () {},
                      );
                    },
                    label: Text(
                      tag,
                      style: context.bodyText2?.copyWith(color: Colors.white),
                    ),
                    backgroundColor: context.secondaryColor,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: halfSpace);
                },
                itemCount: tags.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({required this.viewModel});

  final GalleryViewModel viewModel;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final DataCubit<bool> _showClearSearchButtonCubit = DataCubit(false);

  GalleryViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _showClearSearchButtonCubit.closeAsync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? searchTextColor = context.isDark ? Colors.white : Colors.grey[900];
    Color? searchHintColor = context.isDark ? Colors.white : Colors.grey[700];

    return BlocBuilder(
      bloc: _viewModel.searchHistoryCubit,
      builder: (context, List<String> history) {
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
            _viewModel.addSearchTag(historyItem);
            AnalyticsHelper.search(historyItem);
          },
          optionsViewBuilder: (context, onSelected, Iterable<String> history) {
            double maxHeight = (context.safeAreaHeight * 2) / 3;
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(right: x2Space),
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
                        horizontal: normalSpace,
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
              _showClearSearchButtonCubit
                  .push(textEditingController.text.isNotEmpty);
            });
            return TextField(
              autofocus: false,
              focusNode: focusNode,
              controller: textEditingController,
              style: context.bodyText2?.copyWith(color: searchTextColor),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: context.secondaryColor,
                ),
                suffixIcon: BlocBuilder(
                  bloc: _showClearSearchButtonCubit,
                  builder: (context, bool showClearButton) {
                    return Visibility(
                      visible: showClearButton,
                      child: IconButton(
                        icon: Icon(Icons.clear, color: context.secondaryColor),
                        onPressed: () {
                          textEditingController.clear();
                        },
                      ),
                    );
                  },
                ),
                hintText: _viewModel.searchHint,
                hintStyle: context.bodyText2?.copyWith(
                  color: searchHintColor,
                  overflow: TextOverflow.ellipsis,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (String searchTerm) {
                textEditingController.clear();
                _viewModel.addSearchTag(searchTerm);
                AnalyticsHelper.search(searchTerm);
              },
            );
          },
        );
      },
    );
  }

  void _removeSearchHistory(String historyItem) {
    context.showYesNoDialog(
      title: _viewModel.removeSearchHistoryTitle,
      content: _viewModel.getSearchHistoryRemovalMessage(historyItem),
      yesLabel: _viewModel.acceptTagRemoval,
      noLabel: _viewModel.cancelTagRemoval,
      yesAction: () => _viewModel.removeSearchHistory(historyItem),
      noAction: () {},
    );
  }
}
