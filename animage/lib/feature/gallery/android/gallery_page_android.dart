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
import 'package:animage/widget/list_update_notification_android.dart';
import 'package:flutter/material.dart';
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

class _GalleryPageAndroidState extends State<GalleryPageAndroid>
    with SingleTickerProviderStateMixin {
  static const String _tag = '_GalleryPageAndroidState';
  final GalleryViewModel _viewModel = GalleryViewModelImpl();
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);
  final DataCubit<bool> _showClearSearchButtonCubit = DataCubit(false);
  final DataCubit<bool> _showTransitionLoadingCubit = DataCubit(false);

  ScrollController? _scrollController;
  StreamSubscription? _scrollToTopSubscription;
  StreamSubscription? _getGallerySubscription;

  late AnimationController _notificationAnimationController;
  late Animation<Offset> _notificationSlideInAnimation;

  late BannerAd _bannerAd;
  bool _isAdReady = false;

  RewardedAd? _firstRewardedAd;
  RewardedAd? _secondRewardedAd;

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
    _notificationAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _notificationSlideInAnimation =
        Tween<Offset>(begin: const Offset(0.0, -5.0), end: Offset.zero)
            .animate(_notificationAnimationController);
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
    _showClearSearchButtonCubit.closeAsync();
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
    Color? unSelectedModeColor = isDark ? Colors.white : Colors.grey[400];

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).backgroundColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Container(
          alignment: Alignment.centerLeft,
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: searchBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: _buildSearchView(context),
        ),
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => NewPostsCubit()),
          ],
          child: SafeArea(
            child: BlocListener(
              bloc: _viewModel.galleryLevelIndexCubit,
              listener: (context, int levelId) {
                _loadRewardedAd(levelId);
              },
              child: BlocBuilder(
                  bloc: _showTransitionLoadingCubit,
                  builder: (context, bool showTransitionLoading) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 8.0),
                          child: BlocBuilder(
                              bloc: _modeCubit,
                              builder: (context, GalleryMode mode) {
                                bool isGrid = mode == GalleryMode.grid;
                                return BlocConsumer(
                                  listener: (context, List<String> tags) {
                                    context
                                        .read<NewPostsCubit>()
                                        .updateTagsList(tags);
                                  },
                                  bloc: _viewModel.tagListCubit,
                                  builder: (context, List<String> tags) {
                                    bool hasTag = tags.isNotEmpty;
                                    List<Widget> bodyWidgets = [
                                      Positioned.fill(
                                          child: Align(
                                        child: Container(
                                          child: BlocBuilder(
                                              bloc: _viewModel.setUpFinishCubit,
                                              builder: (context,
                                                  bool setUpFinished) {
                                                return setUpFinished
                                                    ? Stack(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        children: [
                                                          RefreshIndicator(
                                                            onRefresh: () =>
                                                                Future.sync(() =>
                                                                    _viewModel
                                                                        .refreshGallery()),
                                                            child: isGrid
                                                                ? _buildPagedGridView(
                                                                    context
                                                                        .secondaryColor)
                                                                : _buildPagedListView(
                                                                    context
                                                                        .secondaryColor),
                                                          ),
                                                          BlocConsumer<
                                                              NewPostsCubit,
                                                              Iterable<
                                                                  String>>(listener:
                                                              (context,
                                                                  Iterable<
                                                                          String>
                                                                      sampleList) {
                                                            if (sampleList
                                                                .isNotEmpty) {
                                                              _notificationAnimationController
                                                                  .forward();
                                                            }
                                                          }, builder: (context,
                                                              Iterable<String>
                                                                  sampleList) {
                                                            return sampleList
                                                                    .isNotEmpty
                                                                ? SlideTransition(
                                                                    position:
                                                                        _notificationSlideInAnimation,
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              8.0),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          _notificationAnimationController
                                                                              .reverse();
                                                                          context
                                                                              .read<NewPostsCubit>()
                                                                              .reset();
                                                                          _viewModel
                                                                              .refreshGallery();
                                                                        },
                                                                        child: ListUpdateNotificationAndroid(
                                                                            message:
                                                                                'New posts',
                                                                            images:
                                                                                sampleList),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Visibility(
                                                                    child:
                                                                        Container(),
                                                                    visible:
                                                                        false,
                                                                  );
                                                          })
                                                        ],
                                                      )
                                                    : Center(
                                                        child: SizedBox(
                                                          width: 32,
                                                          height: 32,
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    context
                                                                        .secondaryColor),
                                                          ),
                                                        ),
                                                      );
                                              }),
                                          margin: EdgeInsets.only(
                                              top: hasTag ? 80.0 : 32.0),
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                        ),
                                        alignment:
                                            AlignmentDirectional.topCenter,
                                      )),
                                      Positioned.fill(
                                          child: Align(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      _viewModel.pageTitle,
                                                      style: context.headline6,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                  ),
                                                  Container(
                                                    height: 32,
                                                    width: 101,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    8.0)),
                                                        border: Border.all(
                                                            color: context
                                                                .secondaryColor)),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: IconButton(
                                                            onPressed: () {
                                                              _modeCubit.push(
                                                                  GalleryMode
                                                                      .list);
                                                              saveGalleryModePref(
                                                                  GalleryMode
                                                                      .list);
                                                              AnalyticsHelper
                                                                  .viewListGallery();
                                                            },
                                                            icon: Icon(
                                                              Icons.list,
                                                              color: isGrid
                                                                  ? unSelectedModeColor
                                                                  : context
                                                                      .secondaryColor,
                                                            ),
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .all(4.0),
                                                          ),
                                                          flex: 1,
                                                        ),
                                                        Container(
                                                          width: 1,
                                                          color: context
                                                              .secondaryColor,
                                                        ),
                                                        Expanded(
                                                          child: IconButton(
                                                            onPressed: () {
                                                              _modeCubit.push(
                                                                  GalleryMode
                                                                      .grid);
                                                              saveGalleryModePref(
                                                                  GalleryMode
                                                                      .grid);
                                                              AnalyticsHelper
                                                                  .viewGridGallery();
                                                            },
                                                            icon: Icon(
                                                                Icons.grid_view,
                                                                color: isGrid
                                                                    ? context
                                                                        .secondaryColor
                                                                    : unSelectedModeColor),
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .all(4.0),
                                                          ),
                                                          flex: 1,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Visibility(
                                                child: Container(
                                                  child: ListView.separated(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        String tag =
                                                            tags[index];
                                                        return Chip(
                                                          deleteIcon:
                                                              const Icon(
                                                                  Icons.close),
                                                          deleteIconColor:
                                                              Colors.white,
                                                          onDeleted: () {
                                                            context
                                                                .showYesNoDialog(
                                                                    title: _viewModel
                                                                        .removeTagTitle,
                                                                    content: _viewModel
                                                                        .getTagRemovalMessage(
                                                                            tag),
                                                                    yesLabel:
                                                                        _viewModel
                                                                            .acceptTagRemoval,
                                                                    yesAction:
                                                                        () {
                                                                      _viewModel
                                                                          .removeSearchTag(
                                                                              tag);
                                                                    },
                                                                    noLabel:
                                                                        _viewModel
                                                                            .cancelTagRemoval,
                                                                    noAction:
                                                                        () {});
                                                          },
                                                          label: Text(
                                                            tag,
                                                            style: context
                                                                .bodyText2
                                                                ?.copyWith(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          backgroundColor: context
                                                              .secondaryColor,
                                                          labelPadding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                        );
                                                      },
                                                      separatorBuilder:
                                                          (context, index) {
                                                        return const SizedBox(
                                                          width: 8.0,
                                                        );
                                                      },
                                                      itemCount: tags.length),
                                                  constraints:
                                                      const BoxConstraints
                                                          .expand(height: 32),
                                                  margin: const EdgeInsets.only(
                                                      top: 8.0),
                                                ),
                                                visible: tags.isNotEmpty,
                                              )
                                            ],
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                        ),
                                        alignment: Alignment.topCenter,
                                      )),
                                    ];
                                    if (_isAdReady) {
                                      bodyWidgets.add(Positioned.fill(
                                          child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          constraints: BoxConstraints.expand(
                                              width: double.infinity,
                                              height: _bannerAd.size.height
                                                  .toDouble()),
                                          color: context.defaultBackgroundColor,
                                          child: SizedBox(
                                            width:
                                                _bannerAd.size.width.toDouble(),
                                            height: _bannerAd.size.height
                                                .toDouble(),
                                            child: AdWidget(ad: _bannerAd),
                                          ),
                                        ),
                                      )));
                                    }
                                    return Stack(
                                      children: bodyWidgets,
                                    );
                                  },
                                );
                              }),
                        ),
                        Visibility(
                          child: Container(
                            color: defaultTransparentGrey,
                            child: Center(
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      context.secondaryColor),
                                ),
                              ),
                            ),
                          ),
                          visible: showTransitionLoading,
                        )
                      ],
                    );
                  }),
            ),
          )),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildPagedGridView(Color brandColor) {
    double cardAspectRatio = 1.0;
    _scrollController?.dispose();
    _scrollController = ScrollController();
    return PagedGridView<int, PostCardUiModel>(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      scrollController: _scrollController,
      pagingController: _viewModel.getPagingController(),
      builderDelegate: PagedChildBuilderDelegate(
          firstPageProgressIndicatorBuilder: (context) =>
              _loadingWidget(brandColor),
          newPageProgressIndicatorBuilder: (context) => Container(
                child: _loadingWidget(brandColor),
                padding: EdgeInsets.only(
                    bottom: _isAdReady ? AdSize.banner.height.toDouble() : 0),
              ),
          itemBuilder: (context, postItem, index) {
            if (index == 0) {
              context.read<NewPostsCubit>().init(postItem.id);
            }
            return GalleryGridItemAndroid(
              uiModel: postItem,
              itemAspectRatio: cardAspectRatio,
              postDetailsCubit: _viewModel.postDetailsCubit,
              onOpenDetail: (postUiModel) {
                _viewModel.requestDetailsPage(postUiModel.id);
              },
              onCloseDetail: () => _viewModel.clearDetailsPageRequest(),
              onFavoriteChanged: (postUiModel) =>
                  _viewModel.toggleFavorite(postUiModel),
              onTagsSelected: _viewModel.addSearchTags,
            );
          }),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: cardAspectRatio,
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0),
    );
  }

  Widget _buildPagedListView(Color brandColor) {
    _scrollController?.dispose();
    _scrollController = ScrollController();
    return PagedListView<int, PostCardUiModel>(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        scrollController: _scrollController,
        pagingController: _viewModel.getPagingController(),
        builderDelegate: PagedChildBuilderDelegate<PostCardUiModel>(
            newPageProgressIndicatorBuilder: (context) => Container(
                  child: _loadingWidget(brandColor),
                  padding: EdgeInsets.only(
                      bottom: _isAdReady ? AdSize.banner.height.toDouble() : 0),
                ),
            firstPageProgressIndicatorBuilder: (context) =>
                _loadingWidget(brandColor),
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
                margin: const EdgeInsets.only(bottom: 8.0),
              );
            }));
  }

  Widget _loadingWidget(Color color) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchView(BuildContext context) {
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
          }, onSelected: (historyItem) {
            _viewModel.addSearchTag(historyItem);
            AnalyticsHelper.search(historyItem);
          }, optionsViewBuilder:
                  (context, onSelected, Iterable<String> history) {
            double maxHeight = (context.safeAreaHeight * 2) / 3;
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(right: 32.0),
                color: context.defaultBackgroundColor,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    children: [TextSpan(text: historyItem)]),
                              ),
                              onTap: () => onSelected(historyItem),
                            )),
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 8),
                                child: Icon(Icons.close,
                                    size: 24, color: context.secondaryColor),
                              ),
                              onTap: () => _removeSearchHistory(historyItem),
                            )
                          ],
                        ),
                      );
                    }),
              ),
            );
          }, fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.secondaryColor,
                  ),
                  suffixIcon: BlocBuilder(
                    bloc: _showClearSearchButtonCubit,
                    builder: (context, bool showClearButton) {
                      return Visibility(
                        child: IconButton(
                          icon:
                              Icon(Icons.clear, color: context.secondaryColor),
                          onPressed: () {
                            textEditingController.clear();
                          },
                        ),
                        visible: showClearButton,
                      );
                    },
                  ),
                  hintText: _viewModel.searchHint,
                  hintStyle: context.bodyText2?.copyWith(
                      color: searchHintColor, overflow: TextOverflow.ellipsis),
                  border: InputBorder.none),
              onSubmitted: (String searchTerm) {
                textEditingController.clear();
                _viewModel.addSearchTag(searchTerm);
                AnalyticsHelper.search(searchTerm);
              },
            );
          });
        });
  }

  void _removeSearchHistory(String historyItem) {
    context.showYesNoDialog(
        title: _viewModel.removeSearchHistoryTitle,
        content: _viewModel.getSearchHistoryRemovalMessage(historyItem),
        yesLabel: _viewModel.acceptTagRemoval,
        noLabel: _viewModel.cancelTagRemoval,
        yesAction: () => _viewModel.removeSearchHistory(historyItem),
        noAction: () {});
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
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            if (isRewardEarned) {
              context.showConfirmationDialog(
                  title: _viewModel.specialOfferEarnedTitle,
                  message: _viewModel.specialOfferEarnedMessage(
                      _viewModel.galleryLevelIndexCubit.state),
                  actionLabel: _viewModel.specialOfferEarnedConfirmLabel,
                  action: () => _viewModel.refreshGallery());
            }
          });

          _firstRewardedAd = ad;

          context.showYesNoDialog(
              title: _viewModel.specialOfferTitle,
              content: _viewModel.specialOfferMessage(1),
              yesLabel: _viewModel.specialOfferAcceptLabel,
              yesAction: () => _firstRewardedAd?.show(onUserEarnedReward:
                      (AdWithoutView ad, RewardItem reward) {
                    if (reward.amount.isFinite) {
                      isRewardEarned = true;
                      _viewModel.enableGalleryLevel(1);
                    }
                  }),
              noLabel: _viewModel.specialOfferDenyLabel,
              noAction: () {});
        },
        onAdFailedToLoad: (err) {
          Log.d('_GalleryPageAndroidState',
              'Failed to load a rewarded ad: ${err.message}');
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
          firstAd.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
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
                                _viewModel.galleryLevelIndexCubit.state),
                            actionLabel:
                                _viewModel.specialOfferEarnedConfirmLabel,
                            action: () => _viewModel.refreshGallery());
                      }
                    }, onAdFailedToShowFullScreenContent: (add, error) {
                      _showTransitionLoadingCubit.push(false);
                    }, onAdShowedFullScreenContent: (ad) {
                      _showTransitionLoadingCubit.push(false);
                    });

                    _secondRewardedAd = secondAd;

                    _secondRewardedAd?.show(onUserEarnedReward:
                        (AdWithoutView ad, RewardItem reward) {
                      if (reward.amount.isFinite) {
                        isSecondRewardEarned = true;
                        _viewModel.enableGalleryLevel(2);
                      }
                    });
                  },
                  onAdFailedToLoad: (err) {
                    Log.d('_GalleryPageAndroidState',
                        'Failed to load a rewarded ad: ${err.message}');
                  },
                ),
              );
            }
          });

          _firstRewardedAd = firstAd;

          context.showYesNoDialog(
              title: _viewModel.specialOfferTitle,
              content: _viewModel.specialOfferMessage(2),
              yesLabel: _viewModel.specialOfferAcceptLabel,
              yesAction: () => _firstRewardedAd?.show(onUserEarnedReward:
                      (AdWithoutView ad, RewardItem reward) {
                    if (reward.amount.isFinite) {
                      isFirstRewardEarned = true;
                      _showTransitionLoadingCubit.push(true);
                    }
                  }),
              noLabel: _viewModel.specialOfferDenyLabel,
              noAction: () {});
        },
        onAdFailedToLoad: (err) {
          Log.d('_GalleryPageAndroidState',
              'Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }
}
