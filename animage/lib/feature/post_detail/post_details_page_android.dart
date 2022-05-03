import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDetailsPageAndroid extends StatefulWidget {
  const PostDetailsPageAndroid({Key? key}) : super(key: key);

  @override
  State<PostDetailsPageAndroid> createState() => _PostDetailsPageAndroidState();
}

class _PostDetailsPageAndroidState extends State<PostDetailsPageAndroid> {
  static const double _defaultGalleryHeight = 500;

  final DataCubit<NavigationBarExpandStatus> _expandStatusCubit =
      DataCubit(NavigationBarExpandStatus.expanded);

  @override
  Widget build(BuildContext context) {
    Post post = ModalRoute.of(context)?.settings.arguments as Post;

    double sampleAspectRatio = post.sampleAspectRatio;
    double galleryHeight = sampleAspectRatio > 0
        ? context.screenWidth / sampleAspectRatio
        : _defaultGalleryHeight;

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
    });

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
                    floating: false,
                    pinned: true,
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
                          CachedNetworkImage(
                            imageUrl: post.sampleUrl ?? '',
                            height: galleryHeight,
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover,
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
        body: Container(),
      ),
    );
  }
}
