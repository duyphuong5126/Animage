import 'package:animage/feature/ui_model/view_original_ui_model.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/fading_app_bar_android.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewOriginalImagePageAndroid extends StatefulWidget {
  const ViewOriginalImagePageAndroid({Key? key}) : super(key: key);

  @override
  State<ViewOriginalImagePageAndroid> createState() =>
      _ViewOriginalImagePageAndroidState();
}

class _ViewOriginalImagePageAndroidState
    extends State<ViewOriginalImagePageAndroid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    ViewOriginalUiModel uiModel =
        ModalRoute.of(context)?.settings.arguments as ViewOriginalUiModel;

    Iterable<String> urls = uiModel.posts
        .map((post) => post.fileUrl ?? '')
        .where((fileUrl) => fileUrl.isNotEmpty);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: FadingAppBarAndroid(
          appBar: AppBar(
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
                systemStatusBarContrastEnforced: true,
                statusBarColor: Color.fromARGB(0, 0, 0, 0)),
            backgroundColor: const Color.fromARGB(100, 0, 0, 0),
          ),
          controller: _animationController),
      body: urls.isNotEmpty
          ? PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              itemCount: urls.length,
              builder: (context, int index) {
                String url = urls.elementAt(index);
                return PhotoViewGalleryPageOptions(
                  minScale: PhotoViewComputedScale.contained * 1.0,
                  imageProvider: CachedNetworkImageProvider(url),
                  onTapUp: (context, details, value) {
                    switch (_animationController.status) {
                      case AnimationStatus.completed:
                        {
                          _animationController.reverse();
                          break;
                        }

                      case AnimationStatus.dismissed:
                        {
                          _animationController.forward();
                          break;
                        }
                      default:
                        break;
                    }
                  },
                );
              },
              loadingBuilder: (context, event) {
                return Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(context.secondaryColor),
                    ),
                  ),
                );
              })
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
