import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../colors.dart';
import '../constant.dart';
import '../feature/home/android/home_page_android.dart';
import '../feature/original_image_page/android/view_original_image_page_android.dart';
import '../feature/post_detail/post_details_page_android.dart';

class AnimageAppAndroidV2 extends StatefulWidget {
  const AnimageAppAndroidV2({super.key, required this.isFromAndroid31});

  final bool isFromAndroid31;

  @override
  State<AnimageAppAndroidV2> createState() => _AnimageAppAndroidV2State();
}

class _AnimageAppAndroidV2State extends State<AnimageAppAndroidV2> {
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
      theme: _getTheme(context),
      routes: {
        '/': (context) => const HomePageAndroid(),
        detailsPageRoute: (context) => const PostDetailsPageAndroid(),
        viewOriginalPageRoute: (context) =>
            const ViewOriginalImagePageAndroid(),
      },
    );
  }

  ThemeData _getTheme(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    bool isDark = brightness == Brightness.dark;
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? grey900 : white,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: brandColor,
        onPrimary: grey900,
        secondary: brandColor,
        onSecondary: white,
        error: Colors.red[900]!,
        onError: white,
        background: isDark ? black : white,
        onBackground: isDark ? white : grey900,
        surface: isDark ? grey800 : grey200,
        onSurface: isDark ? white : grey900,
        surfaceVariant: isDark ? white : grey600,
      ),
      textTheme: Theme.of(context).textTheme.apply(
            displayColor: isDark ? white : grey900,
            bodyColor: isDark ? white : grey900,
          ),
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
