import 'dart:ui';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/post_detail/post_details_view_model.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/feature/ui_model/detail_result_ui_model.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/feature/ui_model/view_original_ui_model.dart';
import 'package:animage/service/analytics_helper.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/service/image_down_load_state.dart';
import 'package:animage/service/image_downloader.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:animage/widget/gallery_list_item_android.dart';
import 'package:animage/widget/text_with_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';

class PostDetailsPageAndroid extends StatefulWidget {
  const PostDetailsPageAndroid({Key? key}) : super(key: key);

  @override
  State<PostDetailsPageAndroid> createState() => _PostDetailsPageAndroidState();
}

class _PostDetailsPageAndroidState extends State<PostDetailsPageAndroid> {
  static const double _defaultGalleryHeight = 500;
  static const double _defaultGalleryFooterHeight = 72;

  final DataCubit<NavigationBarExpandStatus> _expandStatusCubit =
      DataCubit(NavigationBarExpandStatus.expanded);

  final DataCubit<bool> _showMasterInfo = DataCubit(false);

  final PostDetailsViewModel _viewModel = PostDetailsViewModelImpl();

  @override
  void dispose() {
    super.dispose();
    _expandStatusCubit.closeAsync();
    _showMasterInfo.closeAsync();
  }

  @override
  Widget build(BuildContext context) {
    Post post = ModalRoute.of(context)?.settings.arguments as Post;
    String? status = post.status;
    String? source = post.source;

    _viewModel.initData(post);

    double sampleAspectRatio = post.sampleAspectRatio;
    double galleryHeight = sampleAspectRatio > 0
        ? context.screenWidth / sampleAspectRatio
        : _defaultGalleryHeight;

    double screenHeight = MediaQuery.of(context).size.height;

    double _galleryFooterVerticalMargin =
        galleryHeight > screenHeight ? galleryHeight - screenHeight : 0;

    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
      bool expanded = position.pixels < (position.maxScrollExtent / 3);
      bool collapsed = position.pixels > ((position.maxScrollExtent * 3) / 4);
      if (expanded) {
        _expandStatusCubit.push(NavigationBarExpandStatus.expanded);
      } else if (collapsed) {
        _expandStatusCubit.push(NavigationBarExpandStatus.collapsed);
      }

      _showMasterInfo.push(position.pixels > _defaultGalleryFooterHeight * 2);
    });

    List<String> tagList = post.tagList;
    List<Widget> tagChipList = [];
    tagChipList.add(
        _buildTitleChip(_viewModel.tagSectionTitle, context.secondaryColor));
    tagChipList.addAll(tagList.map((tag) => GestureDetector(
          onTap: () {
            Navigator.of(context).pop(DetailResultUiModel(selectedTags: [tag]));
          },
          child: _buildChip(tag, context.secondaryColor),
        )));

    return WillPopScope(
        child: Scaffold(
          backgroundColor: context.defaultBackgroundColor,
          body: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                BlocBuilder(
                    bloc: _expandStatusCubit,
                    builder: (context, expandStatus) {
                      bool isExpanded =
                          expandStatus == NavigationBarExpandStatus.expanded;
                      Brightness statusBarIconBrightness = context.isDark
                          ? Brightness.light
                          : isExpanded
                              ? Brightness.light
                              : Brightness.dark;
                      return SliverAppBar(
                        systemOverlayStyle: SystemUiOverlayStyle(
                            statusBarIconBrightness: statusBarIconBrightness,
                            statusBarColor: Colors.transparent),
                        foregroundColor:
                            isExpanded ? Colors.white : context.primaryColor,
                        backgroundColor: context.defaultBackgroundColor,
                        elevation: 1,
                        shadowColor: context.defaultShadowColor,
                        expandedHeight: galleryHeight,
                        snap: false,
                        floating: false,
                        pinned: true,
                        actions: [
                          BlocBuilder(
                              bloc: _expandStatusCubit,
                              builder: (context, expandStatus) {
                                bool isExpanded = expandStatus ==
                                    NavigationBarExpandStatus.expanded;
                                return Visibility(
                                  child: BlocBuilder(
                                      bloc: FavoriteService.favoriteListCubit,
                                      builder:
                                          (context, List<int> favoriteList) {
                                        bool isFavorite =
                                            favoriteList.contains(post.id);
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              right: 16.0),
                                          child: FavoriteCheckbox(
                                            size: 28,
                                            color: context.secondaryColor,
                                            isFavorite: isFavorite,
                                            onFavoriteChanged: (newFavStatus) =>
                                                _viewModel.toggleFavorite(post),
                                          ),
                                        );
                                      }),
                                  visible: !isExpanded,
                                );
                              })
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Visibility(
                            child: Text(
                              'ID: ${post.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(color: context.primaryColor),
                            ),
                            visible: !isExpanded,
                          ),
                          background: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _viewModel.requestViewOriginal(post),
                                    child: CachedNetworkImage(
                                      imageUrl: post.sampleUrl ?? '',
                                      alignment: Alignment.topCenter,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  ClipRect(
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: _defaultGalleryFooterHeight +
                                          _galleryFooterVerticalMargin,
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 50.0,
                                          sigmaY: 50.0,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: BlocBuilder(
                                            bloc: _viewModel
                                                .sampleImageDominantColorCubit,
                                            builder:
                                                (context, Color dominantColor) {
                                              double luminance = dominantColor
                                                  .computeLuminance();
                                              Color brandColor = luminance > 0.5
                                                  ? accentColorDark
                                                  : accentColor;
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        _defaultGalleryFooterHeight,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                            child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            BlocBuilder(
                                                              bloc: _viewModel
                                                                  .artistCubit,
                                                              builder: (context,
                                                                  ArtistUiModel?
                                                                      artist) {
                                                                return Text(
                                                                  _viewModel
                                                                      .getArtistLabel(
                                                                          artist),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: context
                                                                      .headline6
                                                                      ?.copyWith(
                                                                          color:
                                                                              brandColor),
                                                                );
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              height: 4.0,
                                                            ),
                                                            Text(
                                                              _viewModel
                                                                  .getScoreLabel(
                                                                      post),
                                                              style: context
                                                                  .bodyText1
                                                                  ?.copyWith(
                                                                      color:
                                                                          brandColor),
                                                            )
                                                          ],
                                                        )),
                                                        BlocBuilder(
                                                            bloc: FavoriteService
                                                                .favoriteListCubit,
                                                            builder: (context,
                                                                List<int>
                                                                    favoriteList) {
                                                              bool isFavorite =
                                                                  favoriteList
                                                                      .contains(
                                                                          post.id);
                                                              return FavoriteCheckbox(
                                                                key: ValueKey(
                                                                    DateTime.now()
                                                                        .millisecondsSinceEpoch),
                                                                size: 32,
                                                                color:
                                                                    brandColor,
                                                                isFavorite:
                                                                    isFavorite,
                                                                onFavoriteChanged:
                                                                    (newFavStatus) =>
                                                                        _viewModel
                                                                            .toggleFavorite(post),
                                                              );
                                                            }),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          _galleryFooterVerticalMargin)
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                  height: kToolbarHeight * 2,
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
                    })
              ];
            },
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: BlocBuilder(
                bloc: _viewModel.childrenCubit,
                builder: (context, List<PostCardUiModel> children) {
                  List<Widget> content = [
                    BlocListener(
                      bloc: ImageDownloader.downloadStateCubit,
                      listener: (context, ImageDownloadState? state) {
                        _processDownloadState(state, post);
                      },
                      child: Visibility(
                        child: Container(),
                        visible: false,
                      ),
                    ),
                    BlocListener(
                      bloc: _viewModel.vieOriginalPostsCubit,
                      listener: (context, ViewOriginalUiModel? uiModel) {
                        if (uiModel != null) {
                          Navigator.of(context).pushNamed(viewOriginalPageRoute,
                              arguments: uiModel);
                          _viewModel.clearViewOriginalRequest();
                        }
                      },
                      child: Visibility(
                        child: Container(),
                        visible: false,
                      ),
                    ),
                    BlocListener(
                      bloc: ImageDownloader.pendingListCubit,
                      listener: (context, String? newPendingUrl) {
                        if (newPendingUrl != null &&
                            newPendingUrl == post.fileUrl) {
                          context.showConfirmationDialog(
                              title: _viewModel.downloadOnHoldTitle,
                              message: _viewModel.downloadOnHoldMessage,
                              actionLabel: _viewModel.downloadOnHoldAction,
                              action: () {});
                        }
                      },
                      child: Visibility(
                        child: Container(),
                        visible: false,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: BlocBuilder(
                          bloc: _showMasterInfo,
                          builder: (context, bool showMasterInfo) {
                            return Visibility(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                  BlocBuilder(
                                    bloc: _viewModel.artistCubit,
                                    builder: (context, ArtistUiModel? artist) {
                                      return Visibility(
                                        child: Text(
                                          artist?.name ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.headline4,
                                        ),
                                        visible: artist != null,
                                      );
                                    },
                                  )
                                ],
                              ),
                              visible: showMasterInfo,
                            );
                          }),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text(
                            post.author ?? '',
                            style: context.headline6,
                          )),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Share.share(post.shareUrl,
                                        subject: 'Illustration ${post.id}');
                                  },
                                  icon: Icon(
                                    Icons.share_rounded,
                                    size: 24,
                                    color: context.primaryColor,
                                  )),
                              const SizedBox(
                                width: 16.0,
                              ),
                              BlocBuilder(
                                bloc: ImageDownloader.downloadStateCubit,
                                builder: (context, ImageDownloadState? state) {
                                  bool isDownloading = state?.state ==
                                          DownloadState.downloading &&
                                      state?.url == post.fileUrl;
                                  return Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Visibility(
                                        child: IconButton(
                                            onPressed: () {
                                              _viewModel
                                                  .startDownloadingOriginalImage(
                                                      post);
                                              AnalyticsHelper.download(post.id);
                                            },
                                            icon: Icon(
                                              Icons.download_rounded,
                                              size: 24,
                                              color: context.primaryColor,
                                            )),
                                        visible: !isDownloading,
                                      ),
                                      Visibility(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 16.0, top: 8.0, right: 8.0),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      context.secondaryColor),
                                            ),
                                          ),
                                        ),
                                        visible: isDownloading,
                                      )
                                    ],
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: tagChipList,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        _viewModel.getRatingLabel(post),
                        style: context.bodyText1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        _viewModel.getCreatedAtTimeStamp(post),
                        style: context.bodyText1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        _viewModel.getUpdatedAtTimeStamp(post),
                        style: context.bodyText1,
                      ),
                    ),
                    Visibility(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          _viewModel.getStatusLabel(post),
                          style: context.bodyText1,
                        ),
                      ),
                      visible: status != null && status.isNotEmpty,
                    ),
                    Visibility(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: TextWithLinks(
                            text: _viewModel.getSourceLabel(post),
                            textStyle: context.bodyText1,
                            linkStyle: context.button
                                ?.copyWith(color: context.secondaryColor)),
                      ),
                      visible: source != null && source.isNotEmpty,
                    ),
                    BlocBuilder(
                        bloc: _viewModel.artistCubit,
                        builder: (context, ArtistUiModel? artist) {
                          List<String> urls = artist?.urls
                                  .where((url) => url.isNotEmpty)
                                  .toList() ??
                              [];
                          return Visibility(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: TextWithLinks(
                                  text: _viewModel.getArtistInfo(urls),
                                  textStyle: context.bodyText1,
                                  linkStyle: context.button?.copyWith(
                                      color: context.secondaryColor)),
                            ),
                            visible: urls.isNotEmpty,
                          );
                        })
                  ];

                  if (children.isNotEmpty) {
                    content.add(Container(
                      margin: const EdgeInsets.only(
                          left: 16.0, top: 16.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _viewModel.getChildrenSectionTitle(children.length),
                            style: context.bodyText1,
                          ),
                          BlocBuilder(
                              bloc:
                                  ImageDownloader.areChildrenDownloadableCubit,
                              builder: (context,
                                  Map<int, bool> childrenDownloadableMap) {
                                bool areChildrenDownloadable =
                                    childrenDownloadableMap[post.id] ?? true;
                                return areChildrenDownloadable
                                    ? TextButton(
                                        onPressed: () {
                                          context.showYesNoDialog(
                                              title: _viewModel
                                                  .downloadChildrenTitle,
                                              content: _viewModel
                                                  .getDownloadChildrenMessage(
                                                      children.length),
                                              yesLabel: _viewModel
                                                  .acceptDownloadChildrenAction,
                                              noLabel: _viewModel
                                                  .cancelDownloadChildrenAction,
                                              yesAction: () {
                                                _viewModel
                                                    .startDownloadAllChildren(
                                                        post.id, children);
                                                AnalyticsHelper
                                                    .downloadChildren(post.id);
                                              },
                                              noAction: () {});
                                        },
                                        child: Text(
                                          _viewModel.downloadChildrenAction,
                                          style: context.button?.copyWith(
                                              color: context.secondaryColor),
                                        ))
                                    : Container(
                                        margin:
                                            const EdgeInsets.only(right: 16.0),
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  context.secondaryColor),
                                        ),
                                      );
                              })
                        ],
                      ),
                    ));
                    content.addAll(children.map((postItem) => Container(
                          margin: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 16.0),
                          child: GalleryListItemAndroid(
                            uiModel: postItem,
                            itemAspectRatio: 1.5,
                            postDetailsCubit: _viewModel.postDetailsCubit,
                            onOpenDetail: (postUiModel) {
                              _viewModel.requestDetailsPage(postUiModel.id);
                            },
                            onCloseDetail: () =>
                                _viewModel.clearDetailsPageRequest(),
                            onFavoriteChanged: (post) =>
                                _viewModel.toggleFavoriteOfPost(post.id),
                            onTagsSelected: (List<String> selectedTags) {},
                          ),
                        )));
                    content.add(const SizedBox(
                      height: 16.0,
                    ));
                  }
                  return ListView(
                    children: content,
                  );
                },
              ),
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.of(context)
              .pop(const DetailResultUiModel(selectedTags: []));
          return true;
        });
  }

  Widget _buildTitleChip(String title, Color color) {
    return Chip(
      labelPadding: const EdgeInsets.all(0.0),
      label: Text(
        title,
        style: context.bodyText1,
      ),
      backgroundColor: context.defaultBackgroundColor,
      padding: const EdgeInsets.all(0.0),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      labelPadding: const EdgeInsets.all(2.0),
      label: Text(
        label,
        style: context.caption?.copyWith(color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.all(8.0),
    );
  }

  void _processDownloadState(ImageDownloadState? state, Post currentPost) {
    String? fileUrl = currentPost.fileUrl;
    if (state == null || state.url != fileUrl) {
      return;
    }
    if (state.state == DownloadState.success) {
      context.showConfirmationDialog(
          title: _viewModel.downloadSuccessTitle,
          message: _viewModel.downloadSuccessMessage,
          actionLabel: _viewModel.downloadResultAction,
          action: () {});
    } else if (state.state == DownloadState.failed) {
      context.showConfirmationDialog(
          title: _viewModel.downloadFailureTitle,
          message: _viewModel.downloadFailureMessage,
          actionLabel: _viewModel.downloadResultAction,
          action: () {});
    }
  }
}
