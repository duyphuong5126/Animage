import 'dart:ui';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/post_detail/post_details_view_model.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:animage/widget/text_with_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
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

  final DataCubit<DownloadState> _downloadStateCubit =
      DataCubit(DownloadState.Idle);

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
    tagChipList.addAll(tagList.map(
        (tag) => _buildChip(tag, context.brandColor, CupertinoColors.white)));

    _viewModel.initData(post);

    double sampleAspectRatio = post.sampleAspectRatio;
    double galleryHeight = sampleAspectRatio > 0
        ? context.screenWidth / sampleAspectRatio
        : _defaultGalleryHeight;

    double screenHeight = MediaQuery.of(context).size.height;

    double _galleryFooterVerticalMargin =
        galleryHeight > screenHeight ? galleryHeight - screenHeight : 0;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(bottom: 8.0),
          automaticallyImplyMiddle: true,
          middle: PlatformText('ID: ${post.id}'),
          trailing: SizedBox(
            width: 100,
            child: BlocBuilder(
              bloc: _downloadStateCubit,
              builder: (context, state) {
                bool isDownloading = state == DownloadState.Downloading;
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
                            margin:
                                const EdgeInsets.only(left: 12.0, right: 8.0),
                          )
                        : CupertinoButton(
                            padding: EdgeInsetsDirectional.zero,
                            onPressed: () async {
                              String? fileUrl = post.fileUrl;
                              if (fileUrl != null && fileUrl.isNotEmpty) {
                                _downloadStateCubit
                                    .emit(DownloadState.Downloading);
                                bool downloaded = await GallerySaver.saveImage(
                                        fileUrl,
                                        albumName: appDirectoryName) ??
                                    false;
                                _downloadStateCubit.emit(DownloadState.Idle);
                                if (downloaded) {
                                  context.showCupertinoConfirmationDialog(
                                      title: 'Downloading Success',
                                      message:
                                          'Full size illustration is downloaded.',
                                      actionLabel: 'OK',
                                      action: () {});
                                }
                              }
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
          child: ListView(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CachedNetworkImage(
                    imageUrl: post.sampleUrl ?? '',
                    height: galleryHeight,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                  ),
                  ClipRect(
                    child: SizedBox(
                      width: double.infinity,
                      height: _defaultGalleryFooterHeight,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 50.0,
                          sigmaY: 50.0,
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: _galleryFooterVerticalMargin,
                              horizontal: 16.0),
                          child: BlocBuilder(
                            bloc: _viewModel.sampleImageDominantColorCubit,
                            builder: (context, Color dominantColor) {
                              double luminance =
                                  dominantColor.computeLuminance();
                              Color textColor = luminance > 0.5
                                  ? context.primaryColor
                                  : CupertinoColors.white;
                              Color favoriteColor = luminance > 0.5
                                  ? accentColorDark
                                  : accentColor;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BlocBuilder(
                                        bloc: _viewModel.artistCubit,
                                        builder:
                                            (context, ArtistUiModel? artist) {
                                          return Text(
                                            artist?.name ?? 'Unknown artist',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.navTitleTextStyle
                                                .copyWith(color: textColor),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      Text(
                                        'Score: ${post.score}',
                                        style: context.textStyle
                                            .copyWith(color: textColor),
                                      )
                                    ],
                                  )),
                                  FavoriteCheckbox(
                                    size: 32,
                                    color: favoriteColor,
                                    isFavorite: false,
                                    onFavoriteChanged: (newFavStatus) {},
                                  )
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                text: 'Artist info: ${urls.join('\n')}',
                                textStyle: context.textStyle,
                                linkStyle: context.actionTextStyle
                                    .copyWith(color: context.brandColor)),
                          ),
                          visible: urls.isNotEmpty,
                        );
                      })
                ],
              )
            ],
          ),
        ));
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
          color: bgColor),
      child: Text(
        label,
        style: context.textStyle.copyWith(color: Colors.white),
      ),
    );
  }
}
