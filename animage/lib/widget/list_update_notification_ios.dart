import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListUpdateNotificationIOS extends StatelessWidget {
  final Iterable<String> images;
  final String message;

  const ListUpdateNotificationIOS(
      {Key? key, required this.message, required this.images})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const Icon(
        CupertinoIcons.arrow_up,
        color: CupertinoColors.white,
        size: 20.0,
      ),
      const SizedBox(
        width: 4.0,
      )
    ];

    List<Widget> imageList = [];
    double imageRadius = 16.0;
    double imageMarginOffset = imageRadius * 0.9;
    double imageMargin = imageMarginOffset * (images.length - 1);
    for (int i = images.length - 1; i >= 0; i--) {
      imageList.add(Container(
        margin: EdgeInsets.only(left: imageMargin),
        child: CircleAvatar(
          radius: imageRadius,
          backgroundColor: CupertinoColors.white,
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(images.elementAt(i)),
            radius: imageRadius - 1,
          ),
        ),
      ));
      imageMargin -= imageMarginOffset;
    }
    children.add(Stack(
      children: imageList,
      alignment: Alignment.topLeft,
    ));
    children.add(const SizedBox(
      width: 8.0,
    ));
    children.add(Text(
      message,
      style: context.navTitleTextStyle.copyWith(
        color: CupertinoColors.white,
      ),
    ));

    double containerVerticalSpace = 8.0;
    double containerRadius = imageRadius + containerVerticalSpace;
    return Container(
      decoration: BoxDecoration(
          color: context.brandColorDayNight,
          borderRadius: BorderRadius.all(Radius.circular(containerRadius))),
      padding: EdgeInsets.symmetric(
          vertical: containerVerticalSpace, horizontal: 16.0),
      child: Row(
        children: children,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
