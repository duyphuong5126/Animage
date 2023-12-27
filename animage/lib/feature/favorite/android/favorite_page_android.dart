import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/favorite/favorite_view_model.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/analytics_helper.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/gallery_grid_item_android.dart';
import 'package:animage/widget/gallery_list_item_android.dart';
import 'package:animage/widget/gallery_mode_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FavoritePage extends StatefulWidget {
  final DataCubit<int> scrollToTopCubit;

  const FavoritePage({Key? key, required this.scrollToTopCubit})
      : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteViewModel _viewModel = FavoriteViewModelImpl();
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);

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
    _scrollToTopSubscription?.cancel();
    _scrollToTopSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _modeCubit,
      builder: (context, GalleryMode mode) {
        bool isGrid = mode == GalleryMode.grid;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: context.defaultBackgroundColor,
            elevation: 0,
            title: BlocBuilder(
              bloc: FavoriteService.favoriteListCubit,
              builder: (context, List<int> favoriteIds) {
                return Text(
                  _viewModel.pageTitle(favoriteIds.length),
                  style: context.headline6,
                );
              },
            ),
            actions: [
              GalleryModeSwitch(
                onModeSelected: (mode) {
                  _modeCubit.push(mode);
                  AnalyticsHelper.viewListFavorite();
                },
                galleryMode: mode,
              ),
            ],
            scrolledUnderElevation: 0.0,
          ),
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(
                top: halfSpace,
                left: halfSpace,
                right: halfSpace,
              ),
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _viewModel.refreshGallery()),
                child: isGrid
                    ? _buildPagedGridView(context.secondaryColor)
                    : _buildPagedListView(context.secondaryColor),
              ),
            ),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

  Widget _buildPagedGridView(Color brandColor) {
    double cardAspectRatio = 1.0;
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
          firstPageProgressIndicatorBuilder: (context) =>
              _loadingWidget(brandColor),
          newPageProgressIndicatorBuilder: (context) =>
              _loadingWidget(brandColor),
          itemBuilder: (context, postItem, index) {
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
              onTagsSelected: (List<String> selectedTags) {},
            );
          },
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: cardAspectRatio,
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
      ),
    );
  }

  Widget _buildPagedListView(Color brandColor) {
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
          newPageProgressIndicatorBuilder: (context) =>
              _loadingWidget(brandColor),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
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
                onTagsSelected: (List<String> selectedTags) {},
              ),
            );
          },
        ),
      ),
    );
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
}
