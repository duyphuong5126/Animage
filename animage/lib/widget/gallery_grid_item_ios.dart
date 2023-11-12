import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/ui_model/detail_result_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryGridItemIOS extends StatefulWidget {
  final PostCardUiModel uiModel;
  final DataCubit<Post?> postDetailsCubit;
  final Function(PostCardUiModel) onOpenDetail;
  final Function() onCloseDetail;
  final Function(PostCardUiModel) onFavoriteChanged;
  final Function(List<String> selectedTags) onTagsSelected;

  const GalleryGridItemIOS({
    Key? key,
    required this.uiModel,
    required this.postDetailsCubit,
    required this.onOpenDetail,
    required this.onCloseDetail,
    required this.onFavoriteChanged,
    required this.onTagsSelected,
  }) : super(key: key);

  @override
  State<GalleryGridItemIOS> createState() => _GalleryGridItemIOSState();
}

class _GalleryGridItemIOSState extends State<GalleryGridItemIOS> {
  @override
  Widget build(BuildContext context) {
    PostCardUiModel uiModel = widget.uiModel;

    return GestureDetector(
      onTap: () => widget.onOpenDetail(uiModel),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              color: context.cardViewBackgroundColor,
              child: CachedNetworkImage(
                imageUrl: uiModel.previewThumbnailUrl,
                width: double.infinity,
                height: double.infinity,
                alignment: FractionalOffset.center,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  constraints: const BoxConstraints.expand(),
                  color: context.cardViewBackgroundColor,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints.expand(height: 64),
              padding: const EdgeInsets.all(8.0),
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
                  Expanded(
                    child: Text(
                      uiModel.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyle
                          .copyWith(color: CupertinoColors.white),
                    ),
                  ),
                  BlocBuilder(
                    bloc: FavoriteService.favoriteListCubit,
                    builder: (context, List<int> favoriteList) {
                      bool isFavorite = favoriteList.contains(uiModel.id);
                      return FavoriteCheckbox(
                        key: ValueKey(DateTime.now()),
                        size: 20,
                        color: context.primaryColor,
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
    );
  }
}
