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
        backgroundColor: Colors.white,
        shadowColor: Colors.grey[400],
        primaryColor: Colors.grey[900],
        // grey[400]
        textTheme: _getTextTheme(context, false),
        dialogBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        shadowColor: Colors.white,
        primaryColor: Colors.white,
        textTheme: _getTextTheme(context, true),
        dialogBackgroundColor: Colors.grey[900],
      ),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const HomePageAndroid(),
        detailsPageRoute: (context) => const PostDetailsPageAndroid(),
        viewOriginalPageRoute: (context) => const ViewOriginalImagePageAndroid()
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
              ?.copyWith(color: isDark ? Colors.white : Colors.grey[900]),
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
