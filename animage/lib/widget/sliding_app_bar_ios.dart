import 'package:flutter/cupertino.dart';

class SlidingAppBarIOS extends StatefulWidget
    implements ObstructingPreferredSizeWidget {
  final CupertinoNavigationBar navigationBar;
  final AnimationController controller;

  const SlidingAppBarIOS(
      {Key? key, required this.navigationBar, required this.controller})
      : super(key: key);

  @override
  State<SlidingAppBarIOS> createState() => _SlidingAppBarIOSState();

  @override
  Size get preferredSize => navigationBar.preferredSize;

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return false;
  }
}

class _SlidingAppBarIOSState extends State<SlidingAppBarIOS> {
  @override
  Widget build(BuildContext context) {
    widget.controller.reverse();

    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -5.0))
          .animate(
        widget.controller,
      ),
      child: widget.navigationBar,
    );
  }
}
