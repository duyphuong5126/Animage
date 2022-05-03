import 'package:animage/constant.dart';
import 'package:animage/feature/home/ios/home_page_ios.dart';
import 'package:animage/feature/post_detail/post_details_page_ios.dart';
import 'package:flutter/cupertino.dart';

class AnimageAppIOS extends StatefulWidget {
  const AnimageAppIOS({Key? key}) : super(key: key);

  @override
  State<AnimageAppIOS> createState() => _AnimageAppIOSState();
}

class _AnimageAppIOSState extends State<AnimageAppIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
          barBackgroundColor: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.white, darkColor: CupertinoColors.black),
          primaryColor: CupertinoDynamicColor.withBrightness(
              color: accentColor, darkColor: accentColorLight)),
      routes: {
        '/': (context) => const HomePageIOS(),
        detailsPageRoute: (context) => const PostDetailsPageIOS()
      },
    );
  }
}
