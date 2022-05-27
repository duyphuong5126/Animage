import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/ui_model/detail_result_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryGridItemAndroid extends StatefulWidget {
  final PostCardUiModel uiModel;
  final double itemAspectRatio;
  final DataCubit<Post?> postDetailsCubit;
  final Function(PostCardUiModel) onOpenDetail;
  final Function() onCloseDetail;
  final Function(PostCardUiModel) onFavoriteChanged;
  final Function(List<String> selectedTags) onTagsSelected;

  const GalleryGridItemAndroid(
      {Key? key,
      required this.uiModel,
      required this.itemAspectRatio,
      required this.postDetailsCubit,
      required this.onOpenDetail,
      required this.onCloseDetail,
      required this.onFavoriteChanged,
      required this.onTagsSelected})
      : super(key: key);

  @override
  State<GalleryGridItemAndroid> createState() => _GalleryGridItemAndroidState();
}

class _GalleryGridItemAndroidState extends State<GalleryGridItemAndroid> {
  final DataCubit<bool> _favoriteCubit = DataCubit(false);

  @override
  void initState() {
    super.initState();
    _favoriteCubit.push(widget.uiModel.isFavorite);
  }

  @override
  void dispose() {
    super.dispose();
    _favoriteCubit.closeAsync();
  }

  @override
  Widget build(BuildContext context) {
    PostCardUiModel uiModel = widget.uiModel;
    BoxFit boxFit = uiModel.previewAspectRatio > widget.itemAspectRatio
        ? BoxFit.cover
        : BoxFit.fitWidth;

    return GestureDetector(
      onTap: () => widget.onOpenDetail(uiModel),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Stack(
          children: [
            Container(
              color: context.cardViewBackgroundColor,
              child: CachedNetworkImage(
                imageUrl: uiModel.previewThumbnailUrl,
                width: double.infinity,
                height: double.infinity,
                alignment: FractionalOffset.topCenter,
                fit: boxFit,
                errorWidget: (context, url, error) => Container(
                  constraints: const BoxConstraints.expand(),
                  color: context.cardViewBackgroundColor,
                ),
              ),
            ),
            Container(
                constraints: const BoxConstraints.expand(height: 64),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocListener(
                      bloc: widget.postDetailsCubit,
                      listener: (context, Post? post) async {
                        if (post != null && post.id == uiModel.id) {
                          final openResult = await Navigator.of(context)
                              .pushNamed(detailsPageRoute, arguments: post);
                          if (openResult is DetailResultUiModel) {
                            _proceedDetailResult(openResult, uiModel);
                          }
                          widget.onCloseDetail();
                        }
                      },
                      child: Visibility(
                        child: Container(),
                        visible: false,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      uiModel.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: Colors.white),
                    )),
                    BlocBuilder(
                        bloc: _favoriteCubit,
                        builder: (context, bool isFavorite) {
                          return FavoriteCheckbox(
                            key: ValueKey(DateTime.now()),
                            size: 20,
                            color: context.secondaryColor,
                            isFavorite: uiModel.isFavorite,
                            onFavoriteChanged: (newFavStatus) =>
                                widget.onFavoriteChanged(uiModel),
                          );
                        })
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
    );
  }

  void _proceedDetailResult(
      DetailResultUiModel resultUiModel, PostCardUiModel uiModel) {
    bool? favoriteResult = resultUiModel.favoriteMap[uiModel.id];
    if (favoriteResult != null) {
      uiModel.isFavorite = favoriteResult;
      _favoriteCubit.push(favoriteResult);
    }
    if (resultUiModel.selectedTags.isNotEmpty) {
      widget.onTagsSelected(resultUiModel.selectedTags);
    }
  }
}
