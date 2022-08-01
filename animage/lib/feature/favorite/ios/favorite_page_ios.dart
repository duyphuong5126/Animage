import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/favorite/favorite_view_model.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/widget/gallery_grid_item_ios.dart';
import 'package:animage/widget/gallery_list_item_ios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoritePageIOS extends StatefulWidget {
  final DataCubit<int> scrollToTopCubit;

  const FavoritePageIOS({Key? key, required this.scrollToTopCubit})
      : super(key: key);

  @override
  State<FavoritePageIOS> createState() => _FavoritePageIOSState();
}

class _FavoritePageIOSState extends State<FavoritePageIOS> {
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);
  final DataCubit<bool> _showCancelSearchCubit = DataCubit(false);
  final FavoriteViewModel _viewModel = FavoriteViewModelImpl();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final DataCubit<NavigationBarExpandStatus> _expandStatusCubit =
      DataCubit(NavigationBarExpandStatus.expanded);

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
        Log.d('Test>>>', 'expanded');
        _expandStatusCubit.push(NavigationBarExpandStatus.expanded);
      } else if (collapsed) {
        Log.d('Test>>>', 'collapsed');
        _expandStatusCubit.push(NavigationBarExpandStatus.collapsed);
      }
    });
    Color? unSelectedModeColor =
        context.isDark ? Colors.white : Colors.grey[400];
    return CupertinoPageScaffold(
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              border: const Border(
                  bottom: BorderSide(
                      width: 0,
                      color: CupertinoDynamicColor.withBrightness(
                          color: transparency, darkColor: transparency))),
              largeTitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_viewModel.pageTitle),
                  Container(
                    child: BlocBuilder(
                        bloc: _modeCubit,
                        builder: (context, mode) {
                          return _buildSwitchModeButton(
                              mode == GalleryMode.grid, unSelectedModeColor);
                        }),
                    margin: const EdgeInsets.only(right: 16.0),
                  )
                ],
              ),
            )
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          child: BlocBuilder(
              bloc: _modeCubit,
              builder: (context, GalleryMode mode) {
                bool isGrid = mode == GalleryMode.grid;
                return BlocListener(
                  bloc: _viewModel.galleryRefreshedAtCubit,
                  listener: (context, int refreshedAt) {
                    Log.d('Test>>>', 'refreshedAt=$refreshedAt');
                    if (refreshedAt > 0 && _refreshController.isRefresh) {
                      _refreshController.refreshCompleted();
                    }
                  },
                  child: BlocBuilder(
                      bloc: _expandStatusCubit,
                      builder: (context, expandStatus) {
                        bool isCollapsed =
                            expandStatus == NavigationBarExpandStatus.collapsed;
                        return Container(
                          margin: EdgeInsets.only(top: isCollapsed ? 100 : 0),
                          child: SmartRefresher(
                              header: ClassicHeader(
                                textStyle: context.navTitleTextStyle,
                                refreshingText: _viewModel.refreshingText,
                                failedText: _viewModel.failedToRefreshText,
                                completeText:
                                    _viewModel.refreshedSuccessfullyText,
                                idleText: _viewModel.refresherIdleText,
                                releaseText: _viewModel.refresherReleaseText,
                              ),
                              enablePullDown: true,
                              controller: _refreshController,
                              onRefresh: () {
                                _viewModel.refreshGallery();
                              },
                              child: isGrid
                                  ? _buildPagedGridView()
                                  : _buildPagedListView()),
                        );
                      }),
                );
              }),
        ),
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
    PagingController<int, PostCardUiModel> pagingController =
        _viewModel.getPagingController();
    return BlocListener(
        bloc: FavoriteService.favoriteUpdatedTimeCubit,
        listener: (context, int updatedAt) {
          if (updatedAt > 0) {
            pagingController.refresh();
          }
        },
        child: PagedGridView<int, PostCardUiModel>(
          scrollController: _scrollController,
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate(
              firstPageProgressIndicatorBuilder: (context) => _loadingWidget(),
              newPageProgressIndicatorBuilder: (context) => _loadingWidget(),
              itemBuilder: (context, postItem, index) {
                return GalleryGridItemIOS(
                  uiModel: postItem,
                  postDetailsCubit: _viewModel.postDetailsCubit,
                  onOpenDetail: (postUiModel) {
                    _viewModel.requestDetailsPage(postUiModel.id);
                  },
                  onCloseDetail: () => _viewModel.clearDetailsPageRequest(),
                  onFavoriteChanged: (postUiModel) =>
                      _viewModel.toggleFavorite(postUiModel),
                  onTagsSelected: (List<String> selectedTags) {},
                );
              }),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 8.0, crossAxisSpacing: 8.0),
        ));
  }

  Widget _buildPagedListView() {
    _scrollController?.dispose();
    _scrollController = ScrollController();
    PagingController<int, PostCardUiModel> pagingController =
        _viewModel.getPagingController();
    return BlocListener(
        bloc: FavoriteService.favoriteUpdatedTimeCubit,
        listener: (context, int updatedAt) {
          if (updatedAt > 0) {
            pagingController.refresh();
          }
        },
        child: PagedListView<int, PostCardUiModel>(
            scrollController: _scrollController,
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<PostCardUiModel>(
                newPageProgressIndicatorBuilder: (context) => _loadingWidget(),
                firstPageProgressIndicatorBuilder: (context) =>
                    _loadingWidget(),
                firstPageErrorIndicatorBuilder: (context) => Center(
                      child: PlatformText(
                        _viewModel.firstPageErrorMessage,
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navTitleTextStyle,
                      ),
                    ),
                noItemsFoundIndicatorBuilder: (context) => Center(
                      child: PlatformText(
                        _viewModel.emptyMessage,
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navTitleTextStyle,
                      ),
                    ),
                itemBuilder: (context, postItem, index) {
                  return Container(
                    child: GalleryListItemIOS(
                      uiModel: postItem,
                      cardAspectRatio: 1.5,
                      postDetailsCubit: _viewModel.postDetailsCubit,
                      onOpenDetail: (postUiModel) {
                        _viewModel.requestDetailsPage(postUiModel.id);
                      },
                      onCloseDetail: () => _viewModel.clearDetailsPageRequest(),
                      onFavoriteChanged: (postUiModel) =>
                          _viewModel.toggleFavorite(postUiModel),
                      onTagsSelected: (List<String> selectedTags) {},
                    ),
                    margin: const EdgeInsets.only(bottom: 24.0),
                  );
                })));
  }

  Widget _loadingWidget() {
    return CupertinoActivityIndicator(
      radius: 16,
      color: context.primaryColor,
    );
  }
}
