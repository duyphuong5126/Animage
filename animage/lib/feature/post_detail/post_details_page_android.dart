import 'dart:ui';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/post_detail/post_details_view_model.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

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
                              CachedNetworkImage(
                                imageUrl: post.sampleUrl ?? '',
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
                                          vertical:
                                              _galleryFooterVerticalMargin,
                                          horizontal: 16.0),
                                      child: BlocBuilder(
                                        bloc: _viewModel
                                            .sampleImageDominantColorCubit,
                                        builder:
                                            (context, Color dominantColor) {
                                          double luminance =
                                              dominantColor.computeLuminance();
                                          Color textColor = luminance > 0.5
                                              ? context.primaryColor
                                              : Colors.white;
                                          Color favoriteColor = luminance > 0.5
                                              ? accentColorDark
                                              : accentColor;
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Artist name',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: context.headline6
                                                        ?.copyWith(
                                                            color: textColor),
                                                  ),
                                                  const SizedBox(
                                                    height: 4.0,
                                                  ),
                                                  Text(
                                                    'Score: ${post.score}',
                                                    style: context.bodyText1
                                                        ?.copyWith(
                                                            color: textColor),
                                                  )
                                                ],
                                              )),
                                              FavoriteCheckbox(
                                                size: 32,
                                                color: favoriteColor,
                                                isFavorite: false,
                                                onFavoriteChanged:
                                                    (newFavStatus) {},
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
                            Text(
                              'Artist name',
                              style: context.headline4,
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
                            onPressed: () {},
                            icon: Icon(
                              Icons.share_rounded,
                              size: 24,
                              color: context.primaryColor,
                            )),
                        const SizedBox(
                          width: 16.0,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.download_rounded,
                              size: 24,
                              color: context.primaryColor,
                            ))
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
                  child: Linkify(
                    onOpen: (link) async {
                      Uri uri = Uri.parse(link.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    text: 'Source: $source',
                    style: context.bodyText1,
                    linkStyle:
                        context.button?.copyWith(color: context.secondaryColor),
                  ),
                ),
                visible: source != null && source.isNotEmpty,
              )
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
}
