import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/home/home_view_model.dart';
import 'package:animage/feature/home/ios/navigation_bar_expand_status.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/utils/theme_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePageIOS extends StatefulWidget {
  const HomePageIOS({Key? key}) : super(key: key);

  @override
  State<HomePageIOS> createState() => _HomePageIOSState();
}

class _HomePageIOSState extends State<HomePageIOS> {
  final DataCubit<NavigationBarExpandStatus> _expandStatusCubit =
      DataCubit(NavigationBarExpandStatus.expanded);
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);
  final DataCubit<bool> _showCancelSearchCubit = DataCubit(false);
  final HomeViewModel _viewModel = HomeViewModelImpl();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.destroy();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
      bool expanded = position.pixels == position.minScrollExtent;
      bool collapsed = position.pixels == position.maxScrollExtent;
      if (expanded) {
        _expandStatusCubit.emit(NavigationBarExpandStatus.expanded);
      } else if (collapsed) {
        _expandStatusCubit.emit(NavigationBarExpandStatus.collapsed);
      }
    });
    TextEditingController _searchEditController = TextEditingController();
    Color? unSelectedModeColor =
        CupertinoTheme.of(context).isDark ? Colors.white : Colors.grey[400];
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
                children: [
                  const Text('Explore'),
                  Container(
                    child: CupertinoButton(
                      child: const Icon(
                        CupertinoIcons.search,
                        size: 32,
                      ),
                      onPressed: () {
                        scrollController
                            .jumpTo(scrollController.position.maxScrollExtent);
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
                        controller: _searchEditController,
                        autofocus: true,
                        suffixIcon: const Icon(
                          CupertinoIcons.clear_circled_solid,
                        ),
                        onChanged: (value) {
                          _showCancelSearchCubit.emit(value.isNotEmpty);
                        },
                        onSubmitted: (value) {
                          Log.d('Test>>>', 'submitted value=$value');
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
                              child: const Text('Cancel'),
                              onPressed: () {
                                Log.d('Test>>>', 'Cancel search');
                                _searchEditController.clear();
                                scrollController.jumpTo(
                                    scrollController.position.minScrollExtent);
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
        body: Container(
          margin: EdgeInsetsDirectional.zero,
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          child: BlocBuilder(
              bloc: _modeCubit,
              builder: (context, GalleryMode mode) {
                bool isGrid = mode == GalleryMode.grid;
                Log.d('Test>>>', 'isGrid=$isGrid');
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    isGrid ? _buildPagedGridView() : _buildPagedListView(),
                    Container(
                      height: 32,
                      width: 101,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          border: Border.all(color: accentColor)),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              onPressed: () {
                                _modeCubit.emit(GalleryMode.list);
                              },
                              child: Icon(
                                CupertinoIcons.list_bullet,
                                color:
                                    isGrid ? unSelectedModeColor : accentColor,
                              ),
                              padding: const EdgeInsetsDirectional.all(4.0),
                            ),
                            flex: 1,
                          ),
                          Container(
                            width: 1,
                            color: accentColor,
                          ),
                          Expanded(
                            child: CupertinoButton(
                              onPressed: () {
                                _modeCubit.emit(GalleryMode.grid);
                              },
                              child: Icon(CupertinoIcons.rectangle_grid_2x2,
                                  color: isGrid
                                      ? accentColor
                                      : unSelectedModeColor),
                              padding: const EdgeInsetsDirectional.all(4.0),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildPagedGridView() {
    return PagedGridView<int, PostCardUiModel>(
      pagingController: _viewModel.getPagingController(),
      builderDelegate: PagedChildBuilderDelegate(
          firstPageProgressIndicatorBuilder: (context) => _loadingWidget(),
          newPageProgressIndicatorBuilder: (context) => _loadingWidget(),
          itemBuilder: (context, postItem, index) {
            return ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Container(
                    color:
                        CupertinoTheme.of(context).getCardViewBackgroundColor(),
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
                            color: accentColor,
                            isFavorite: false,
                            onFavoriteChanged: (newFavStatus) {},
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
            );
          }),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 8.0, crossAxisSpacing: 8.0),
    );
  }

  Widget _buildPagedListView() {
    return PagedListView<int, PostCardUiModel>(
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
              Log.d('Test>>>',
                  'sample=${postItem.sampleUrl} aspectRatio=${postItem.sampleAspectRatio}');
              BoxFit sampleBoxFit = postItem.sampleAspectRatio > cardAspectRatio
                  ? BoxFit.cover
                  : BoxFit.fitWidth;
              return Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  child: AspectRatio(
                    aspectRatio: cardAspectRatio,
                    child: Container(
                      color: CupertinoTheme.of(context)
                          .getCardViewBackgroundColor(),
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
                                    child: Text(
                                      postItem.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ),
                                  FavoriteCheckbox(
                                    size: 28,
                                    color: accentColor,
                                    isFavorite: false,
                                    onFavoriteChanged: (newFavStatus) {},
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
                margin: const EdgeInsets.only(bottom: 24.0),
              );
            }));
  }

  Widget _loadingWidget() {
    return const CupertinoActivityIndicator(
      radius: 16,
      color: accentColor,
    );
  }
}
