import 'dart:ui';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/post_detail/post_details_view_model.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/feature/ui_model/favorite_changed_ui_model.dart';
import 'package:animage/service/image_down_load_state.dart';
import 'package:animage/service/image_downloader.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:animage/widget/removable_chip_ios.dart';
import 'package:animage/widget/text_with_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:share/share.dart';

class PostDetailsPageIOS extends StatefulWidget {
  const PostDetailsPageIOS({Key? key}) : super(key: key);

  @override
  State<PostDetailsPageIOS> createState() => _PostDetailsPageIOSState();
}

class _PostDetailsPageIOSState extends State<PostDetailsPageIOS> {
  static const double _defaultGalleryHeight = 100;
  static const double _defaultGalleryFooterHeight = 72;

  final PostDetailsViewModel _viewModel = PostDetailsViewModelImpl();

  DataCubit<bool>? _showPinnedMasterSectionCubit = DataCubit(false);

  @override
  Widget build(BuildContext context) {
    Post post = ModalRoute.of(context)?.settings.arguments as Post;
    String? status = post.status;
    String? source = post.source;

    List<String> tagList = post.tagList;
    List<Widget> tagChipList = [];
    tagChipList.add(Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Tags: ',
        style: context.textStyle,
      ),
    ));
    tagChipList.addAll(tagList.map((tag) => RemovableChipIOS(
          label: tag,
          bgColor: context.brandColor,
          textColor: CupertinoColors.white,
          allowRemoval: false,
          onRemove: () {},
        )));

    _viewModel.initData(post);

    double sampleAspectRatio = post.sampleAspectRatio;
    double galleryHeight = sampleAspectRatio > 0
        ? context.screenWidth / sampleAspectRatio
        : _defaultGalleryHeight;

    ScrollController scrollController = ScrollController();

    double safeAreaHeight = context.safeAreaHeight;

    bool isGalleryOutOfScreen = galleryHeight > safeAreaHeight;

    _showPinnedMasterSectionCubit?.push(isGalleryOutOfScreen);

    return WillPopScope(
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.only(bottom: 8.0),
              automaticallyImplyMiddle: true,
              middle: PlatformText('ID: ${post.id}'),
              trailing: SizedBox(
                width: 100,
                child: BlocBuilder(
                  bloc: ImageDownloader.downloadStateCubit,
                  builder: (context, ImageDownloadState? state) {
                    bool isDownloading =
                        state?.state == DownloadState.downloading &&
                            state?.url == post.fileUrl;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                            padding: EdgeInsetsDirectional.zero,
                            onPressed: () {
                              Share.share(post.shareUrl,
                                  subject: 'Illustration ${post.id}');
                            },
                            child: Icon(
                              CupertinoIcons.share,
                              color: context.primaryColor,
                            )),
                        const SizedBox(
                          width: 4.0,
                        ),
                        isDownloading
                            ? Container(
                                child: CupertinoActivityIndicator(
                                  radius: 12,
                                  color: context.primaryColor,
                                ),
                                margin: const EdgeInsets.only(
                                    left: 12.0, right: 8.0),
                              )
                            : CupertinoButton(
                                padding: EdgeInsetsDirectional.zero,
                                onPressed: () async {
                                  _viewModel
                                      .startDownloadingOriginalImage(post);
                                },
                                child: Icon(
                                  CupertinoIcons.cloud_download,
                                  color: context.primaryColor,
                                )),
                        const SizedBox(
                          width: 4.0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            child: SafeArea(
              child: NotificationListener(
                child: Stack(
                  alignment: Alignment.bottomCenter,
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
                        if (newPendingUrl != null &&
                            newPendingUrl == post.fileUrl) {
                          context.showCupertinoConfirmationDialog(
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
                    ListView(
                      controller: scrollController,
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            GestureDetector(
                              child: CachedNetworkImage(
                                imageUrl: post.sampleUrl ?? '',
                                height: galleryHeight,
                                alignment: Alignment.topCenter,
                                fit: BoxFit.fitWidth,
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    viewOriginalPage,
                                    arguments: post);
                              },
                            ),
                            _getMasterInfoSection(post)
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 16.0,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(
                                    post.author ?? '',
                                    style: context.navTitleTextStyle,
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
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
                                'Rating: ${_viewModel.getRatingLabel(post)}',
                                style: context.textStyle,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Created at: ${_viewModel.getCreatedAtTimeStamp(post)}',
                                style: context.textStyle,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Updated at: ${_viewModel.getUpdatedAtTimeStamp(post)}',
                                style: context.textStyle,
                              ),
                            ),
                            Visibility(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  'Status: $status',
                                  style: context.textStyle,
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
                                    textStyle: context.textStyle,
                                    linkStyle: context.actionTextStyle
                                        .copyWith(color: context.brandColor)),
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
                                          text:
                                              'Artist info: ${urls.join('\n')}',
                                          textStyle: context.textStyle,
                                          linkStyle: context.actionTextStyle
                                              .copyWith(
                                                  color: context.brandColor)),
                                    ),
                                    visible: urls.isNotEmpty,
                                  );
                                })
                          ],
                        )
                      ],
                    ),
                    BlocBuilder(
                        bloc: _showPinnedMasterSectionCubit,
                        builder: (context, bool showPinnedMasterSection) {
                          return Visibility(
                            child: _getMasterInfoSection(post),
                            visible: showPinnedMasterSection,
                          );
                        })
                  ],
                ),
                onNotification: (event) {
                  if (event is ScrollNotification) {
                    bool reachDefaultMasterSection =
                        safeAreaHeight + scrollController.position.pixels >
                            galleryHeight;
                    _showPinnedMasterSectionCubit?.push(
                        !reachDefaultMasterSection && isGalleryOutOfScreen);
                  }
                  return false;
                },
              ),
            )),
        onWillPop: () async {
          Navigator.of(context).pop(FavoriteChangedUiModel(
              postId: post.id,
              isFavorite: _viewModel.favoriteStateCubit.state));
          return true;
        });
  }

  @override
  void dispose() {
    super.dispose();
    _showPinnedMasterSectionCubit?.closeAsync();
    _showPinnedMasterSectionCubit = null;
  }

  Widget _getMasterInfoSection(Post post) {
    return ClipRect(
      child: SizedBox(
        width: double.infinity,
        height: _defaultGalleryFooterHeight,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 50.0,
            sigmaY: 50.0,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder(
              bloc: _viewModel.sampleImageDominantColorCubit,
              builder: (context, Color dominantColor) {
                double luminance = dominantColor.computeLuminance();
                Color brandColor =
                    luminance > 0.5 ? accentColorDark : accentColor;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder(
                          bloc: _viewModel.artistCubit,
                          builder: (context, ArtistUiModel? artist) {
                            return Text(
                              artist?.name ?? 'Unknown artist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.navTitleTextStyle
                                  .copyWith(color: brandColor),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          'Score: ${post.score}',
                          style: context.textStyle.copyWith(color: brandColor),
                        )
                      ],
                    )),
                    BlocBuilder(
                        bloc: _viewModel.favoriteStateCubit,
                        builder: (context, bool isFavorite) {
                          return Container(
                            margin: const EdgeInsets.only(right: 16.0),
                            child: FavoriteCheckbox(
                              key: ValueKey(
                                  DateTime.now().millisecondsSinceEpoch),
                              size: 32,
                              color: brandColor,
                              isFavorite: isFavorite,
                              onFavoriteChanged: (newFavStatus) =>
                                  _viewModel.toggleFavorite(post, isFavorite),
                            ),
                          );
                        })
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _processDownloadState(ImageDownloadState? state, Post currentPost) {
    String? fileUrl = currentPost.fileUrl;
    if (state == null || state.url != fileUrl) {
      return;
    }
    if (state.state == DownloadState.success) {
      context.showCupertinoConfirmationDialog(
          title: 'Download Success',
          message: 'Original illustration is downloaded.',
          actionLabel: 'OK',
          action: () {});
    } else if (state.state == DownloadState.failed) {
      context.showCupertinoConfirmationDialog(
          title: 'Download Failed',
          message: 'Could not download original illustration.',
          actionLabel: 'OK',
          action: () {});
    }
  }
}
