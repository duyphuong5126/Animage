import 'package:animage/feature/home/android/home_page_android.dart';
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
          // dark
          backgroundColor: Colors.white,
          // white
          shadowColor: Colors.grey[400],
          // grey[400]
          textTheme: _getTextTheme(context)),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          // light
          backgroundColor: Colors.black,
          // white
          shadowColor: Colors.white,
          // white
          textTheme: _getTextTheme(context)),
      themeMode: ThemeMode.system,
      routes: {'/': (context) => const HomePageAndroid()},
    );
  }

  TextTheme _getTextTheme(BuildContext context) {
    return Theme.of(context).textTheme.copyWith(
        bodyText1: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(color: Colors.grey[900]),
        bodyText2: Theme.of(context)
            .textTheme
            .bodyText2
            ?.copyWith(color: Colors.grey[900]));
  }
}
