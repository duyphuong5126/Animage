import 'package:flutter/material.dart';

class SlidingAppBarAndroid extends StatefulWidget
    implements PreferredSizeWidget {
  final AppBar appBar;
  final AnimationController controller;

  const SlidingAppBarAndroid(
      {Key? key, required this.appBar, required this.controller})
      : super(key: key);

  @override
  State<SlidingAppBarAndroid> createState() => _SlidingAppBarAndroidState();

  @override
  Size get preferredSize => appBar.preferredSize;
}

class _SlidingAppBarAndroidState extends State<SlidingAppBarAndroid> {
  @override
  Widget build(BuildContext context) {
    widget.controller.reverse();

    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -5.0))
          .animate(
        widget.controller,
      ),
      child: widget.appBar,
    );
  }
}
