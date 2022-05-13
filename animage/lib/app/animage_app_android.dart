import 'package:animage/constant.dart';
import 'package:animage/feature/home/android/home_page_android.dart';
import 'package:animage/feature/original_image_page/view_original_image_page_android.dart';
import 'package:animage/feature/post_detail/post_details_page_android.dart';
import 'package:flutter/material.dart';

class AnimageAppAndroid extends StatefulWidget {
  const AnimageAppAndroid({Key? key}) : super(key: key);

  @override
  State<AnimageAppAndroid> createState() => _AnimageAppAndroidState();
}

class _AnimageAppAndroidState extends State<AnimageAppAndroid> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          shadowColor: Colors.grey[400],
          primaryColor: Colors.grey[900],
          // grey[400]
          textTheme: _getTextTheme(context, false)),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          shadowColor: Colors.white,
          primaryColor: Colors.white,
          textTheme: _getTextTheme(context, true)),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const HomePageAndroid(),
        detailsPageRoute: (context) => const PostDetailsPageAndroid(),
        viewOriginalPage: (context) => const ViewOriginalImagePageAndroid()
      },
    );
  }

  TextTheme _getTextTheme(BuildContext context, bool isDark) {
    return Theme.of(context).textTheme.copyWith(
        headline4: Theme.of(context)
            .textTheme
            .headline4
            ?.copyWith(color: isDark ? Colors.white : Colors.grey[900]),
        headline5: Theme.of(context)
            .textTheme
            .headline5
            ?.copyWith(color: isDark ? Colors.white : Colors.grey[900]),
        headline6: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(color: isDark ? Colors.white : Colors.grey[900]),
        bodyText1: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(color: isDark ? Colors.white : Colors.grey[900]),
        bodyText2: Theme.of(context)
            .textTheme
            .bodyText2
            ?.copyWith(color: isDark ? Colors.white : Colors.grey[900]));
  }
}
