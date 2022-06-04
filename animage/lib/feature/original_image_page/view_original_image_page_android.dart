import 'package:animage/feature/original_image_page/view_original_image_view_model.dart';
import 'package:animage/feature/ui_model/view_original_ui_model.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/widget/fading_app_bar_android.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

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

  late final ViewOriginalViewModel _viewModel = ViewOriginalViewModelImpl();

  @override
  Widget build(BuildContext context) {
    ViewOriginalUiModel uiModel =
        ModalRoute.of(context)?.settings.arguments as ViewOriginalUiModel;

    Iterable<String> urls = uiModel.posts
        .map((post) => post.fileUrl ?? '')
        .where((fileUrl) => fileUrl.isNotEmpty);

    if (urls.isNotEmpty) {
      _viewModel.onGalleryItemSelected(0, urls.length);
    }

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
            title: BlocBuilder(
                bloc: _viewModel.galleryTitle,
                builder: (context, String title) {
                  return Visibility(
                    child: Text(title),
                    visible: title.isNotEmpty,
                  );
                }),
          ),
          controller: _animationController),
      body: urls.isNotEmpty
          ? PageView.builder(
              itemCount: urls.length,
              onPageChanged: (int pageIndex) =>
                  _viewModel.onGalleryItemSelected(pageIndex, urls.length),
              itemBuilder: (context, int index) {
                String url = urls.elementAt(index);
                return PhotoView(
                  enableRotation: true,
                  minScale: PhotoViewComputedScale.contained * 1.0,
                  imageProvider: CachedNetworkImageProvider(url),
                  loadingBuilder: (context, event) {
                    return Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              context.secondaryColor),
                        ),
                      ),
                    );
                  },
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
