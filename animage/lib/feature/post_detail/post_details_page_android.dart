import 'dart:ui';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/post_detail/post_details_view_model.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/service/image_down_load_state.dart';
import 'package:animage/service/image_downloader.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
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
        _expandStatusCubit.emit(NavigationBarExpandStatus.expanded);
      } else if (collapsed) {
        _expandStatusCubit.emit(NavigationBarExpandStatus.collapsed);
      }

      _showMasterInfo.emit(position.pixels > _defaultGalleryFooterHeight * 2);
    });

    List<String> tagList = post.tagList;
    List<Widget> tagChipList = [];
    tagChipList.add(_buildTitleChip('Tags: ', context.secondaryColor));
    tagChipList
        .addAll(tagList.map((tag) => _buildChip(tag, context.secondaryColor)));

    return Scaffold(
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
                              child: Container(
                                margin: const EdgeInsets.only(right: 16.0),
                                child: FavoriteCheckbox(
                                  size: 28,
                                  color: context.secondaryColor,
                                  isFavorite: false,
                                  onFavoriteChanged: (newFavStatus) {},
                                ),
                              ),
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
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      viewOriginalPage,
                                      arguments: post);
                                },
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
                                          double luminance =
                                              dominantColor.computeLuminance();
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
                                                              artist?.name ??
                                                                  'Unknown artist',
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
                                                          'Score: ${post.score}',
                                                          style: context
                                                              .bodyText1
                                                              ?.copyWith(
                                                                  color:
                                                                      brandColor),
                                                        )
                                                      ],
                                                    )),
                                                    FavoriteCheckbox(
                                                      size: 32,
                                                      color: brandColor,
                                                      isFavorite: false,
                                                      onFavoriteChanged:
                                                          (newFavStatus) {},
                                                    )
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
          child: ListView(
            children: [
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
                bloc: ImageDownloader.pendingListCubit,
                listener: (context, String? newPendingUrl) {
                  if (newPendingUrl != null && newPendingUrl == post.fileUrl) {
                    context.showConfirmationDialog(
                        title: 'Download On Hold',
                        message:
                            'This post is added to pending list. Please wait.',
                        actionLabel: 'OK',
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
                            bool isDownloading =
                                state?.state == DownloadState.downloading &&
                                    state?.url == post.fileUrl;
                            return Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Visibility(
                                  child: IconButton(
                                      onPressed: () => _viewModel
                                          .startDownloadingOriginalImage(post),
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
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'Rating: ${_viewModel.getRatingLabel(post)}',
                  style: context.bodyText1,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'Created at: ${_viewModel.getCreatedAtTimeStamp(post)}',
                  style: context.bodyText1,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'Updated at: ${_viewModel.getUpdatedAtTimeStamp(post)}',
                  style: context.bodyText1,
                ),
              ),
              Visibility(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'Status: $status',
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
                      text: 'Source: $source',
                      textStyle: context.bodyText1,
                      linkStyle: context.button
                          ?.copyWith(color: context.secondaryColor)),
                ),
                visible: source != null && source.isNotEmpty,
              ),
              BlocBuilder(
                  bloc: _viewModel.artistCubit,
                  builder: (context, ArtistUiModel? artist) {
                    List<String> urls =
                        artist?.urls.where((url) => url.isNotEmpty).toList() ??
                            [];
                    return Visibility(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: TextWithLinks(
                            text: 'Artist info: ${urls.join('\n')}',
                            textStyle: context.bodyText1,
                            linkStyle: context.button
                                ?.copyWith(color: context.secondaryColor)),
                      ),
                      visible: urls.isNotEmpty,
                    );
                  })
            ],
          ),
        ),
      ),
    );
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
          title: 'Download Success',
          message: 'Original illustration is downloaded.',
          actionLabel: 'OK',
          action: () {});
    } else if (state.state == DownloadState.failed) {
      context.showConfirmationDialog(
          title: 'Download Failed',
          message: 'Could not download original illustration.',
          actionLabel: 'OK',
          action: () {});
    }
  }
}
