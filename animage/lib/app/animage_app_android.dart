import 'package:animage/constant.dart';
import 'package:animage/feature/home/android/home_page_android.dart';
import 'package:animage/feature/original_image_page/android/view_original_image_page_android.dart';
import 'package:animage/feature/post_detail/post_details_page_android.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AnimageAppAndroid extends StatefulWidget {
  const AnimageAppAndroid({Key? key, required this.isFromAndroid31})
      : super(key: key);

  final bool isFromAndroid31;

  @override
  State<AnimageAppAndroid> createState() => _AnimageAppAndroidState();
}

class _AnimageAppAndroidState extends State<AnimageAppAndroid> {
  @override
  void initState() {
    super.initState();
    _initNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: widget.isFromAndroid31
          ? ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
            )
          : null,
      theme: ThemeData(
        brightness: Brightness.light,
        shadowColor: Colors.grey[400],
        primaryColor: Colors.grey[900],
        // grey[400]
        textTheme: _getTextTheme(context, false),
        dialogBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[200],
        dividerColor: Colors.grey[500],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        shadowColor: Colors.white,
        primaryColor: Colors.white,
        textTheme: _getTextTheme(context, true),
        dialogBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.black,
          backgroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[800],
        dividerColor: Colors.grey[500],
      ),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const HomePageAndroid(),
        detailsPageRoute: (context) => const PostDetailsPageAndroid(),
        viewOriginalPageRoute: (context) =>
            const ViewOriginalImagePageAndroid(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics.instance,
          nameExtractor: (RouteSettings settings) {
            String? routeName = settings.name;
            switch (settings.name) {
              case detailsPageRoute:
                routeName = postDetailsPage;
                break;

              case viewOriginalPageRoute:
                routeName = viewOriginalPage;
                break;

              case '/':
                routeName = home;
                break;
            }
            return routeName;
          },
        ),
      ],
    );
  }

  TextTheme _getTextTheme(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final textColor = isDark ? Colors.white : Colors.grey[900];
    return theme.textTheme.copyWith(
      headline4: theme.textTheme.headline4?.copyWith(color: textColor),
      headline5: theme.textTheme.headline5?.copyWith(color: textColor),
      headline6: theme.textTheme.headline6?.copyWith(color: textColor),
      bodyText1: theme.textTheme.bodyText1?.copyWith(color: textColor),
      bodyText2: theme.textTheme.bodyText2?.copyWith(color: textColor),
      subtitle2: theme.textTheme.subtitle2?.copyWith(color: textColor),
      caption: theme.textTheme.caption?.copyWith(color: textColor),
    );
  }

  void _initNotificationSettings() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      macOS: null,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _selectNotification,
    );
  }

  Future _selectNotification(NotificationResponse? response) async {
    //Handle notification tapped logic here
  }
}
