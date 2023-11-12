import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/detail_result_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryListItemAndroid extends StatefulWidget {
  final PostCardUiModel uiModel;
  final double itemAspectRatio;
  final DataCubit<Post?> postDetailsCubit;
  final Function(PostCardUiModel) onOpenDetail;
  final Function() onCloseDetail;
  final Function(PostCardUiModel) onFavoriteChanged;
  final Function(List<String> selectedTags) onTagsSelected;

  const GalleryListItemAndroid({
    Key? key,
    required this.uiModel,
    required this.itemAspectRatio,
    required this.postDetailsCubit,
    required this.onOpenDetail,
    required this.onCloseDetail,
    required this.onFavoriteChanged,
    required this.onTagsSelected,
  }) : super(key: key);

  @override
  State<GalleryListItemAndroid> createState() => _GalleryListItemAndroidState();
}

class _GalleryListItemAndroidState extends State<GalleryListItemAndroid> {
  @override
  Widget build(BuildContext context) {
    PostCardUiModel uiModel = widget.uiModel;
    BoxFit boxFit = uiModel.sampleAspectRatio > widget.itemAspectRatio
        ? BoxFit.cover
        : BoxFit.fitWidth;

    ArtistUiModel? artistUiModel = uiModel.artist;
    return GestureDetector(
      onTap: () => widget.onOpenDetail(uiModel),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        child: AspectRatio(
          aspectRatio: widget.itemAspectRatio,
          child: Container(
            color: context.cardViewBackgroundColor,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                BlocListener(
                  bloc: widget.postDetailsCubit,
                  listener: (context, Post? post) async {
                    if (post != null && post.id == uiModel.id) {
                      final openResult = await Navigator.of(context)
                          .pushNamed(detailsPageRoute, arguments: post);
                      if (openResult is DetailResultUiModel &&
                          openResult.selectedTags.isNotEmpty) {
                        widget.onTagsSelected(openResult.selectedTags);
                      }
                      widget.onCloseDetail();
                    }
                  },
                  child: Visibility(
                    visible: false,
                    child: Container(),
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: uiModel.sampleUrl,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: FractionalOffset.topCenter,
                  errorWidget: (context, url, error) => Container(
                    constraints: const BoxConstraints.expand(),
                    color: context.cardViewBackgroundColor,
                  ),
                  fit: boxFit,
                ),
                Container(
                  constraints: const BoxConstraints.expand(height: 80),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              uiModel.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(color: Colors.white),
                            ),
                            Visibility(
                              visible: artistUiModel != null,
                              child: Text(
                                artistUiModel?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    ?.copyWith(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      BlocBuilder(
                        bloc: FavoriteService.favoriteListCubit,
                        builder: (context, List<int> favoriteList) {
                          bool isFavorite = favoriteList.contains(uiModel.id);
                          return FavoriteCheckbox(
                            key: ValueKey(DateTime.now()),
                            size: 28,
                            color: context.secondaryColor,
                            isFavorite: isFavorite,
                            onFavoriteChanged: (newFavStatus) =>
                                widget.onFavoriteChanged(uiModel),
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
