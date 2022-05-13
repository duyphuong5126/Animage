import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class ViewOriginalImagePageIOS extends StatefulWidget {
  const ViewOriginalImagePageIOS({Key? key}) : super(key: key);

  @override
  State<ViewOriginalImagePageIOS> createState() =>
      _ViewOriginalImagePageIOSState();
}

class _ViewOriginalImagePageIOSState extends State<ViewOriginalImagePageIOS> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: 500),
        () => SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
            .copyWith(statusBarBrightness: Brightness.dark)));
    Post post = ModalRoute.of(context)?.settings.arguments as Post;

    String? url = post.fileUrl;
    return CupertinoPageScaffold(
      child: url != null && url.isNotEmpty
          ? Stack(
              alignment: Alignment.topLeft,
              children: [
                PhotoView(
                  imageProvider: CachedNetworkImageProvider(url),
                  loadingBuilder: (context, event) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        radius: 16,
                        color: context.primaryColor,
                      ),
                    );
                  },
                ),
                Container(
                  height: 150,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: transparency,
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsetsDirectional.zero,
                    child: Icon(
                      CupertinoIcons.back,
                      color: context.brandColorDayNight,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
