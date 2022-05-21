import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/gallery/gallery_view_model.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:animage/widget/removable_chip_ios.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GalleryPageIOS extends StatefulWidget {
  final DataCubit<int> scrollToTopCubit;

  const GalleryPageIOS({Key? key, required this.scrollToTopCubit})
      : super(key: key);

  @override
  State<GalleryPageIOS> createState() => _GalleryPageIOSState();
}

class _GalleryPageIOSState extends State<GalleryPageIOS> {
  static const double _switchModeSectionHeight = 52;
  static const double _defaultTagListHeight = 32;

  final DataCubit<NavigationBarExpandStatus> _expandStatusCubit =
      DataCubit(NavigationBarExpandStatus.expanded);
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);
  final DataCubit<bool> _showCancelSearchCubit = DataCubit(false);
  final GalleryViewModel _viewModel = GalleryViewModelImpl();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController? _scrollController;
  StreamSubscription? _scrollToTopSubscription;

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
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.destroy();
    _modeCubit.closeAsync();
    _showCancelSearchCubit.closeAsync();
    _refreshController.dispose();
    _scrollController?.dispose();
    _scrollToTopSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
      bool expanded = position.pixels == position.minScrollExtent;
      bool collapsed = position.pixels == position.maxScrollExtent;
      if (expanded) {
        _expandStatusCubit.push(NavigationBarExpandStatus.expanded);
      } else if (collapsed) {
        _expandStatusCubit.push(NavigationBarExpandStatus.collapsed);
      }
    });
    TextEditingController searchEditController = TextEditingController();
    Color? unSelectedModeColor =
        context.isDark ? Colors.white : Colors.grey[400];
    return CupertinoPageScaffold(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                CupertinoSliverNavigationBar(
                  border: const Border(
                      bottom: BorderSide(
                          width: 0,
                          color: CupertinoDynamicColor.withBrightness(
                              color: transparency, darkColor: transparency))),
                  largeTitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_viewModel.pageTitle),
                      Container(
                        child: CupertinoButton(
                          padding: EdgeInsetsDirectional.zero,
                          child: const Icon(
                            CupertinoIcons.search,
                            size: 32,
                          ),
                          onPressed: () {
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                          },
                        ),
                        margin: const EdgeInsets.only(right: 8),
                      )
                    ],
                  ),
                  middle: BlocBuilder(
                    bloc: _expandStatusCubit,
                    builder: (context, expandStatus) {
                      return Visibility(
                        child: Container(
                          child: CupertinoSearchTextField(
                            controller: searchEditController,
                            autofocus: false,
                            suffixIcon: const Icon(
                              CupertinoIcons.clear_circled_solid,
                            ),
                            onChanged: (value) {
                              _showCancelSearchCubit.push(value.isNotEmpty);
                            },
                            onSubmitted: (String searchTerm) {
                              searchEditController.clear();
                              _viewModel.addSearchTag(searchTerm);
                            },
                          ),
                          margin: const EdgeInsets.only(left: 8, right: 8),
                        ),
                        visible:
                            expandStatus == NavigationBarExpandStatus.collapsed,
                      );
                    },
                  ),
                  trailing: BlocBuilder(
                      bloc: _expandStatusCubit,
                      builder: (context, expandStatus) {
                        return BlocBuilder(
                          bloc: _showCancelSearchCubit,
                          builder: (context, bool showCancelSearchButton) {
                            return Visibility(
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child:
                                      Text(_viewModel.cancelSearchButtonLabel),
                                  onPressed: () {
                                    Log.d('Test>>>', 'Cancel search');
                                    searchEditController.clear();
                                    scrollController.jumpTo(scrollController
                                        .position.minScrollExtent);
                                  }),
                              visible: showCancelSearchButton &&
                                  expandStatus ==
                                      NavigationBarExpandStatus.collapsed,
                            );
                          },
                        );
                      }),
                )
              ];
            },
            body: BlocBuilder(
                bloc: _viewModel.setUpFinishCubit,
                builder: (context, bool setUpFinished) {
                  return setUpFinished
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 16.0),
                          child: BlocBuilder(
                              bloc: _modeCubit,
                              builder: (context, GalleryMode mode) {
                                bool isGrid = mode == GalleryMode.grid;
                                return BlocBuilder(
                                  bloc: _viewModel.tagListCubit,
                                  builder: (context, List<String> tags) {
                                    bool hasTag = tags.isNotEmpty;
                                    return Stack(
                                      alignment: AlignmentDirectional.topEnd,
                                      children: [
                                        BlocListener(
                                          bloc: _viewModel.postDetailsCubit,
                                          listener: (context, post) async {
                                            if (post != null) {
                                              await Navigator.of(context)
                                                  .pushNamed(detailsPageRoute,
                                                      arguments: post);
                                              _viewModel
                                                  .clearDetailsPageRequest();
                                            }
                                          },
                                          child: BlocListener(
                                            bloc: _viewModel
                                                .galleryRefreshedAtCubit,
                                            listener:
                                                (context, int refreshedAt) {
                                              Log.d('Test>>>',
                                                  'refreshedAt=$refreshedAt');
                                              if (refreshedAt > 0 &&
                                                  _refreshController
                                                      .isRefresh) {
                                                _refreshController
                                                    .refreshCompleted();
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: _switchModeSectionHeight +
                                                      (hasTag
                                                          ? _defaultTagListHeight
                                                          : 0)),
                                              child: SmartRefresher(
                                                  header: ClassicHeader(
                                                    textStyle: context
                                                        .navTitleTextStyle,
                                                    refreshingText: _viewModel
                                                        .refreshingText,
                                                    failedText: _viewModel
                                                        .failedToRefreshText,
                                                    completeText: _viewModel
                                                        .refreshedSuccessfullyText,
                                                    idleText: _viewModel
                                                        .refresherIdleText,
                                                    releaseText: _viewModel
                                                        .refresherReleaseText,
                                                  ),
                                                  enablePullDown: true,
                                                  controller:
                                                      _refreshController,
                                                  onRefresh: () {
                                                    _viewModel.refreshGallery();
                                                  },
                                                  child: isGrid
                                                      ? _buildPagedGridView()
                                                      : _buildPagedListView()),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            _buildSwitchModeButton(
                                                isGrid, unSelectedModeColor),
                                            SizedBox(
                                              height: hasTag ? 10.0 : 0.0,
                                            ),
                                            Container(
                                                child: ListView.separated(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      String tag = tags[index];
                                                      return RemovableChipIOS(
                                                          label: tag,
                                                          bgColor: context
                                                              .brandColor,
                                                          textColor:
                                                              CupertinoColors
                                                                  .white,
                                                          allowRemoval: true,
                                                          onRemove: () {
                                                            context
                                                                .showCupertinoYesNoDialog(
                                                                    title:
                                                                        'REMOVE TAG',
                                                                    message:
                                                                        'Remove tag $tag?',
                                                                    yesLabel:
                                                                        'Yes',
                                                                    yesAction:
                                                                        () {
                                                                      _viewModel
                                                                          .removeSearchTag(
                                                                              tag);
                                                                    },
                                                                    noLabel:
                                                                        'No',
                                                                    noAction:
                                                                        () {});
                                                          });
                                                    },
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return const SizedBox(
                                                        width: 8.0,
                                                      );
                                                    },
                                                    itemCount: tags.length),
                                                constraints:
                                                    const BoxConstraints.expand(
                                                        height: 32)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                        )
                      : Center(
                          child: _loadingWidget(),
                        );
                }),
          ),
          BlocBuilder(
              bloc: _modeCubit,
              builder: (context, mode) {
                return BlocBuilder(
                    bloc: _expandStatusCubit,
                    builder: (context, expandStatus) {
                      return Visibility(
                        child: BlocBuilder(
                            bloc: _viewModel.tagListCubit,
                            builder: (context, List<String> tags) {
                              bool hasTag = tags.isNotEmpty;
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: hasTag ? 8.0 : 0),
                                width: double.infinity,
                                height: _switchModeSectionHeight +
                                    (hasTag
                                        ? _defaultTagListHeight + 16.0
                                        : 0.0),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _viewModel.pageTitle,
                                          style: context.navTitleTextStyle,
                                        ),
                                        _buildSwitchModeButton(
                                            mode == GalleryMode.grid,
                                            unSelectedModeColor),
                                      ],
                                    ),
                                    SizedBox(
                                      height: hasTag ? 12.0 : 0,
                                    ),
                                    Container(
                                        child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              String tag = tags[index];
                                              return RemovableChipIOS(
                                                  label: tag,
                                                  bgColor: context.brandColor,
                                                  textColor:
                                                      CupertinoColors.white,
                                                  allowRemoval: true,
                                                  onRemove: () {
                                                    context
                                                        .showCupertinoYesNoDialog(
                                                            title: 'REMOVE TAG',
                                                            message:
                                                                'Remove tag $tag?',
                                                            yesLabel: 'Yes',
                                                            yesAction: () {
                                                              _viewModel
                                                                  .removeSearchTag(
                                                                      tag);
                                                            },
                                                            noLabel: 'No',
                                                            noAction: () {});
                                                  });
                                            },
                                            separatorBuilder: (context, index) {
                                              return const SizedBox(
                                                width: 8.0,
                                              );
                                            },
                                            itemCount: tags.length),
                                        constraints: BoxConstraints.expand(
                                            height: hasTag ? 32 : 0)),
                                  ],
                                ),
                                margin: const EdgeInsets.only(
                                    top: kToolbarHeight + 32,
                                    left: 16.0,
                                    right: 16.0),
                              );
                            }),
                        visible:
                            expandStatus == NavigationBarExpandStatus.collapsed,
                      );
                    });
              })
        ],
      ),
    );
  }

  Widget _buildSwitchModeButton(bool isGrid, Color? unSelectedModeColor) {
    return Container(
      height: 32,
      width: 101,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(color: context.primaryColor)),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              onPressed: () {
                _modeCubit.push(GalleryMode.list);
              },
              child: Icon(
                CupertinoIcons.list_bullet,
                color: isGrid ? unSelectedModeColor : context.primaryColor,
              ),
              padding: const EdgeInsetsDirectional.all(4.0),
            ),
            flex: 1,
          ),
          Container(
            width: 1,
            color: context.primaryColor,
          ),
          Expanded(
            child: CupertinoButton(
              onPressed: () {
                _modeCubit.push(GalleryMode.grid);
              },
              child: Icon(CupertinoIcons.rectangle_grid_2x2,
                  color: isGrid ? context.primaryColor : unSelectedModeColor),
              padding: const EdgeInsetsDirectional.all(4.0),
            ),
            flex: 1,
          )
        ],
      ),
    );
  }

  Widget _buildPagedGridView() {
    _scrollController?.dispose();
    _scrollController = ScrollController();
    return PagedGridView<int, PostCardUiModel>(
      scrollController: _scrollController,
      pagingController: _viewModel.getPagingController(),
      builderDelegate: PagedChildBuilderDelegate(
          firstPageProgressIndicatorBuilder: (context) => _loadingWidget(),
          newPageProgressIndicatorBuilder: (context) => _loadingWidget(),
          itemBuilder: (context, postItem, index) {
            return GestureDetector(
              onTap: () => _viewModel.requestDetailsPage(postItem.id),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    Container(
                      color: context.cardViewBackgroundColor,
                      child: CachedNetworkImage(
                        imageUrl: postItem.previewThumbnailUrl,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: FractionalOffset.center,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                        constraints: const BoxConstraints.expand(height: 64),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(
                              postItem.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(color: Colors.white),
                            )),
                            FavoriteCheckbox(
                              size: 20,
                              color: context.primaryColor,
                              isFavorite: postItem.isFavorite,
                              onFavoriteChanged: (newFavStatus) {
                                _viewModel.toggleFavorite(postItem);
                              },
                            )
                          ],
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ]),
                        ))
                  ],
                ),
              ),
            );
          }),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 8.0, crossAxisSpacing: 8.0),
    );
  }

  Widget _buildPagedListView() {
    _scrollController?.dispose();
    _scrollController = ScrollController();
    return PagedListView<int, PostCardUiModel>(
        scrollController: _scrollController,
        pagingController: _viewModel.getPagingController(),
        builderDelegate: PagedChildBuilderDelegate<PostCardUiModel>(
            newPageProgressIndicatorBuilder: (context) => _loadingWidget(),
            firstPageProgressIndicatorBuilder: (context) => _loadingWidget(),
            firstPageErrorIndicatorBuilder: (context) => Center(
                  child: PlatformText(
                    _viewModel.firstPageErrorMessage,
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                ),
            noItemsFoundIndicatorBuilder: (context) => Center(
                  child: PlatformText(
                    _viewModel.emptyMessage,
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                ),
            itemBuilder: (context, postItem, index) {
              double cardAspectRatio = 1.5;
              BoxFit sampleBoxFit = postItem.sampleAspectRatio > cardAspectRatio
                  ? BoxFit.cover
                  : BoxFit.fitWidth;

              ArtistUiModel? artistUiModel = postItem.artist;
              return Container(
                child: GestureDetector(
                  onTap: () => _viewModel.requestDetailsPage(postItem.id),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: AspectRatio(
                      aspectRatio: cardAspectRatio,
                      child: Container(
                        color: context.cardViewBackgroundColor,
                        child: Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: [
                            CachedNetworkImage(
                              imageUrl: postItem.sampleUrl,
                              width: double.infinity,
                              height: double.infinity,
                              alignment: FractionalOffset.topCenter,
                              fit: sampleBoxFit,
                            ),
                            Container(
                                constraints:
                                    const BoxConstraints.expand(height: 80),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            postItem.author,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          Visibility(
                                            child: Text(
                                              artistUiModel?.name ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  ?.copyWith(
                                                      color: Colors.white),
                                            ),
                                            visible: artistUiModel != null,
                                          )
                                        ],
                                      ),
                                    ),
                                    FavoriteCheckbox(
                                      size: 28,
                                      color: context.primaryColor,
                                      isFavorite: postItem.isFavorite,
                                      onFavoriteChanged: (newFavStatus) {
                                        _viewModel.toggleFavorite(postItem);
                                      },
                                    )
                                  ],
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Color.fromARGB(200, 0, 0, 0),
                                        Color.fromARGB(0, 0, 0, 0)
                                      ]),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 24.0),
              );
            }));
  }

  Widget _loadingWidget() {
    return CupertinoActivityIndicator(
      radius: 16,
      color: context.primaryColor,
    );
  }
}
