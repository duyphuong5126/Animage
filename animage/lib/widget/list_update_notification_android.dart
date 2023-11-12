import 'package:animage/utils/material_context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ListUpdateNotificationAndroid extends StatelessWidget {
  final Iterable<String> images;
  final String message;

  const ListUpdateNotificationAndroid({
    Key? key,
    required this.message,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const Icon(
        Icons.arrow_upward,
        color: Colors.white,
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
      imageList.add(
        Container(
          margin: EdgeInsets.only(left: imageMargin),
          child: CircleAvatar(
            radius: imageRadius,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(images.elementAt(i)),
              radius: imageRadius - 1,
            ),
          ),
        ),
      );
      imageMargin -= imageMarginOffset;
    }
    children.add(
      Stack(
        alignment: Alignment.topLeft,
        children: imageList,
      ),
    );
    children.add(
      const SizedBox(
        width: 8.0,
      ),
    );
    children.add(
      Text(
        message,
        style: context.bodyText1?.copyWith(
          color: Colors.white,
        ),
      ),
    );

    double containerVerticalSpace = 8.0;
    double containerRadius = imageRadius + containerVerticalSpace;
    return Container(
      decoration: BoxDecoration(
        color: context.brandColorDayNight,
        borderRadius: BorderRadius.all(Radius.circular(containerRadius)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: containerVerticalSpace,
        horizontal: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
