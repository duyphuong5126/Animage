import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/feature/gallery/gallery_view_model.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/gallery_grid_item_android.dart';
import 'package:animage/widget/gallery_list_item_android.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GalleryPageAndroid extends StatefulWidget {
  final DataCubit<int> scrollToTopCubit;

  const GalleryPageAndroid({Key? key, required this.scrollToTopCubit})
      : super(key: key);

  @override
  State<GalleryPageAndroid> createState() => _GalleryPageAndroidState();
}

class _GalleryPageAndroidState extends State<GalleryPageAndroid> {
  final GalleryViewModel _viewModel = GalleryViewModelImpl();
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);
  final DataCubit<bool> _showClearSearchButtonCubit = DataCubit(false);

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
    _showClearSearchButtonCubit.closeAsync();
    _scrollToTopSubscription?.cancel();
    _scrollToTopSubscription = null;
    _scrollController?.dispose();
    _scrollController = null;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchEditingController = TextEditingController();
    searchEditingController.addListener(() {
      _showClearSearchButtonCubit.push(searchEditingController.text.isNotEmpty);
    });
    bool isDark = context.isDark;

    Color? searchBackgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];
    Color? searchTextColor = isDark ? Colors.white : Colors.grey[900];
    Color? searchHintColor = isDark ? Colors.white : Colors.grey[700];
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
          child: TextField(
            autofocus: false,
            controller: searchEditingController,
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
                        icon: Icon(Icons.clear, color: context.secondaryColor),
                        onPressed: () {
                          searchEditingController.clear();
                        },
                      ),
                      visible: showClearButton,
                    );
                  },
                ),
                hintText: 'Type something...',
                hintStyle: context.bodyText2?.copyWith(color: searchHintColor),
                border: InputBorder.none),
            onSubmitted: (String searchTerm) {
              searchEditingController.clear();
              _viewModel.addSearchTag(searchTerm);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
          child: BlocBuilder(
              bloc: _modeCubit,
              builder: (context, GalleryMode mode) {
                bool isGrid = mode == GalleryMode.grid;
                return BlocBuilder(
                  bloc: _viewModel.tagListCubit,
                  builder: (context, List<String> tags) {
                    bool hasTag = tags.isNotEmpty;
                    Log.d('Test>>>', 'tags=$tags');
                    return Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        Container(
                          child: BlocBuilder(
                              bloc: _viewModel.setUpFinishCubit,
                              builder: (context, bool setUpFinished) {
                                return setUpFinished
                                    ? RefreshIndicator(
                                        onRefresh: () => Future.sync(
                                            () => _viewModel.refreshGallery()),
                                        child: isGrid
                                            ? _buildPagedGridView(
                                                context.secondaryColor)
                                            : _buildPagedListView(
                                                context.secondaryColor),
                                      )
                                    : Center(
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    context.secondaryColor),
                                          ),
                                        ),
                                      );
                              }),
                          margin: EdgeInsets.only(top: hasTag ? 80.0 : 32.0),
                          padding: const EdgeInsets.only(top: 16.0),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      _viewModel.pageTitle,
                                      style: context.headline6,
                                    ),
                                    margin: const EdgeInsets.only(left: 8.0),
                                  ),
                                  Container(
                                    height: 32,
                                    width: 101,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0)),
                                        border: Border.all(
                                            color: context.secondaryColor)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: IconButton(
                                            onPressed: () {
                                              _modeCubit.push(GalleryMode.list);
                                            },
                                            icon: Icon(
                                              Icons.list,
                                              color: isGrid
                                                  ? unSelectedModeColor
                                                  : context.secondaryColor,
                                            ),
                                            padding:
                                                const EdgeInsetsDirectional.all(
                                                    4.0),
                                          ),
                                          flex: 1,
                                        ),
                                        Container(
                                          width: 1,
                                          color: context.secondaryColor,
                                        ),
                                        Expanded(
                                          child: IconButton(
                                            onPressed: () {
                                              _modeCubit.push(GalleryMode.grid);
                                            },
                                            icon: Icon(Icons.grid_view,
                                                color: isGrid
                                                    ? context.secondaryColor
                                                    : unSelectedModeColor),
                                            padding:
                                                const EdgeInsetsDirectional.all(
                                                    4.0),
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
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        String tag = tags[index];
                                        return Chip(
                                          deleteIcon: const Icon(Icons.close),
                                          deleteIconColor: Colors.white,
                                          onDeleted: () {
                                            context.showYesNoDialog(
                                                title: 'REMOVE TAG',
                                                content: 'Remove tag "$tag"?',
                                                yesLabel: 'Yes',
                                                noLabel: 'No',
                                                yesAction: () {
                                                  _viewModel
                                                      .removeSearchTag(tag);
                                                },
                                                noAction: () {});
                                          },
                                          label: Text(
                                            tag,
                                            style: context.bodyText2
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          backgroundColor:
                                              context.secondaryColor,
                                          labelPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(
                                          width: 8.0,
                                        );
                                      },
                                      itemCount: tags.length),
                                  constraints:
                                      const BoxConstraints.expand(height: 32),
                                  margin: const EdgeInsets.only(top: 8.0),
                                ),
                                visible: tags.isNotEmpty,
                              )
                            ],
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                        )
                      ],
                    );
                  },
                );
              }),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildPagedGridView(Color brandColor) {
    double cardAspectRatio = 1.0;
    _scrollController?.dispose();
    _scrollController = ScrollController();
    return PagedGridView<int, PostCardUiModel>(
      scrollController: _scrollController,
      pagingController: _viewModel.getPagingController(),
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
        scrollController: _scrollController,
        pagingController: _viewModel.getPagingController(),
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
}