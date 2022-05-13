import 'package:flutter/material.dart';

class FadingAppBarAndroid extends StatefulWidget
    implements PreferredSizeWidget {
  final AppBar appBar;
  final AnimationController controller;

  const FadingAppBarAndroid(
      {Key? key, required this.appBar, required this.controller})
      : super(key: key);

  @override
  State<FadingAppBarAndroid> createState() => _FadingAppBarAndroidState();

  @override
  Size get preferredSize => appBar.preferredSize;
}

class _FadingAppBarAndroidState extends State<FadingAppBarAndroid> {
  @override
  Widget build(BuildContext context) {
    widget.controller.forward();

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeOut,
      ),
      child: widget.appBar,
    );
  }
}
