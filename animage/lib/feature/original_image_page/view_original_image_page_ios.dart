import 'package:animage/constant.dart';
import 'package:animage/feature/original_image_page/view_original_image_view_model.dart';
import 'package:animage/feature/ui_model/view_original_ui_model.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewOriginalImagePageIOS extends StatefulWidget {
  const ViewOriginalImagePageIOS({Key? key}) : super(key: key);

  @override
  State<ViewOriginalImagePageIOS> createState() =>
      _ViewOriginalImagePageIOSState();
}

class _ViewOriginalImagePageIOSState extends State<ViewOriginalImagePageIOS> {
  late final ViewOriginalViewModel _viewModel = ViewOriginalViewModelImpl();

  @override
  Widget build(BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: 500),
        () => SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
            .copyWith(statusBarBrightness: Brightness.dark)));

    ViewOriginalUiModel uiModel =
        ModalRoute.of(context)?.settings.arguments as ViewOriginalUiModel;

    Iterable<String> urls = uiModel.posts
        .map((post) => post.fileUrl ?? '')
        .where((fileUrl) => fileUrl.isNotEmpty);

    if (urls.isNotEmpty) {
      _viewModel.onGalleryItemSelected(0, urls.length);
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: urls.isNotEmpty
          ? Stack(
              alignment: Alignment.topLeft,
              children: [
                PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    itemCount: urls.length,
                    onPageChanged: (int index) {
                      _viewModel.onGalleryItemSelected(index, urls.length);
                    },
                    builder: (context, int index) {
                      String url = urls.elementAt(index);
                      return PhotoViewGalleryPageOptions(
                        minScale: PhotoViewComputedScale.contained * 1.0,
                        imageProvider: CachedNetworkImageProvider(url),
                      );
                    },
                    loadingBuilder: (context, event) {
                      return Center(
                        child: CupertinoActivityIndicator(
                          radius: 16,
                          color: context.primaryColor,
                        ),
                      );
                    }),
                Container(
                  height: 150,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: transparency,
                  ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsetsDirectional.zero,
                        child: const Icon(
                          CupertinoIcons.back,
                          size: 32,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      BlocBuilder(
                          bloc: _viewModel.galleryTitle,
                          builder: (context, String title) {
                            return Visibility(
                              child: Text(
                                title,
                                style: context.navTitleTextStyle.copyWith(
                                    color: context.brandColorDayNight),
                              ),
                              visible: title.isNotEmpty,
                            );
                          })
                    ],
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
