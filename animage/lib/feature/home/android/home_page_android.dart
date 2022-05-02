import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/home/home_view_model.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:animage/utils/theme_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePageAndroid extends StatefulWidget {
  const HomePageAndroid({Key? key}) : super(key: key);

  @override
  State<HomePageAndroid> createState() => _HomePageAndroidState();
}

class _HomePageAndroidState extends State<HomePageAndroid> {
  final HomeViewModel _viewModel = HomeViewModelImpl();
  final DataCubit<GalleryMode> _modeCubit = DataCubit(GalleryMode.list);

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
    TextEditingController searchEditingController = TextEditingController();
    bool isDark = Theme.of(context).isDark;

    Color? searchBackgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];
    Color? searchTextColor = isDark ? Colors.white : Colors.grey[900];
    Color? searchHintColor = isDark ? Colors.white : Colors.grey[700];
    Color brandColor = isDark ? accentColorLight : accentColor;
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
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: searchBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Center(
            child: TextField(
              controller: searchEditingController,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(color: searchTextColor),
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: brandColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: brandColor),
                    onPressed: () {
                      searchEditingController.clear();
                    },
                  ),
                  hintText: 'Search...',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: searchHintColor),
                  border: InputBorder.none),
            ),
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
                Log.d('Test>>>', 'isGrid=$isGrid');
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Container(
                      child: isGrid
                          ? _buildPagedGridView()
                          : _buildPagedListView(brandColor),
                      margin: const EdgeInsets.only(top: 32.0),
                      padding: const EdgeInsets.only(top: 8.0),
                    ),
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
                            child: IconButton(
                              onPressed: () {
                                _modeCubit.emit(GalleryMode.list);
                              },
                              icon: Icon(
                                Icons.list,
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
                            child: IconButton(
                              onPressed: () {
                                _modeCubit.emit(GalleryMode.grid);
                              },
                              icon: Icon(Icons.grid_view,
                                  color: isGrid
                                      ? accentColor
                                      : unSelectedModeColor),
                              padding: const EdgeInsetsDirectional.all(4.0),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    )
                  ],
                );
              }),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildPagedGridView() {
    return PagedGridView<int, PostCardUiModel>(
      pagingController: _viewModel.getPagingController(),
      builderDelegate:
          PagedChildBuilderDelegate(itemBuilder: (context, postItem, index) {
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).getCardViewBackgroundColor(),
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
                  child: Text(
                    postItem.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(color: Colors.white),
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color.fromARGB(150, 0, 0, 0),
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

  Widget _buildPagedListView(Color brandColor) {
    return PagedListView<int, PostCardUiModel>(
        pagingController: _viewModel.getPagingController(),
        builderDelegate: PagedChildBuilderDelegate<PostCardUiModel>(
            newPageProgressIndicatorBuilder: (context) => Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                    ),
                  ),
                ),
            firstPageProgressIndicatorBuilder: (context) => Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                    ),
                  ),
                ),
            firstPageErrorIndicatorBuilder: (context) => Center(
                  child: PlatformText(
                    _viewModel.firstPageErrorMessage,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
            noItemsFoundIndicatorBuilder: (context) => Center(
                  child: PlatformText(
                    _viewModel.emptyMessage,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
            itemBuilder: (context, postItem, index) {
              return Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  child: Container(
                    color: Theme.of(context).getCardViewBackgroundColor(),
                    constraints: const BoxConstraints.expand(height: 200),
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        CachedNetworkImage(
                          imageUrl: postItem.sampleUrl,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: FractionalOffset.topCenter,
                          fit: BoxFit.fitWidth,
                        ),
                        Container(
                            constraints:
                                const BoxConstraints.expand(height: 80),
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              postItem.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(color: Colors.white),
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Color.fromARGB(150, 0, 0, 0),
                                    Color.fromARGB(0, 0, 0, 0)
                                  ]),
                            ))
                      ],
                    ),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 8.0),
              );
            }));
  }
}
