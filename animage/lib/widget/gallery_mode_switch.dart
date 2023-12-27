import 'package:animage/constant.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:flutter/material.dart';

class GalleryModeSwitch extends StatelessWidget {
  const GalleryModeSwitch({
    Key? key,
    required this.onModeSelected,
    required this.galleryMode,
  }) : super(key: key);

  final Function(GalleryMode) onModeSelected;
  final GalleryMode galleryMode;

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDark;
    Color? unSelectedModeColor = isDark ? Colors.white : Colors.grey[400];
    final isGrid = galleryMode == GalleryMode.grid;
    return SizedBox(
      height: x2Space,
      width: 109,
      child: Container(
        margin: const EdgeInsets.only(right: halfSpace),
        height: halfSpace,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(halfSpace)),
          border: Border.all(color: context.secondaryColor),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => onModeSelected(GalleryMode.list),
                icon: Icon(
                  Icons.list,
                  color: isGrid ? unSelectedModeColor : context.secondaryColor,
                ),
                padding: const EdgeInsetsDirectional.all(quarterSpace),
              ),
            ),
            Container(
              width: 1,
              color: context.secondaryColor,
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => onModeSelected(GalleryMode.grid),
                icon: Icon(
                  Icons.grid_view,
                  color: isGrid ? context.secondaryColor : unSelectedModeColor,
                ),
                padding: const EdgeInsetsDirectional.all(quarterSpace),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
