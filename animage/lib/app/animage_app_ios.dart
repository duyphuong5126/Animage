import 'package:animage/constant.dart';
import 'package:animage/feature/home/ios/home_page_ios.dart';
import 'package:animage/feature/original_image_page/view_original_image_page_ios.dart';
import 'package:animage/feature/post_detail/post_details_page_ios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AnimageAppIOS extends StatefulWidget {
  const AnimageAppIOS({Key? key}) : super(key: key);

  @override
  State<AnimageAppIOS> createState() => _AnimageAppIOSState();
}

class _AnimageAppIOSState extends State<AnimageAppIOS> {
  @override
  void initState() {
    super.initState();
    _initNotificationSettings();
  }

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
        detailsPageRoute: (context) => const PostDetailsPageIOS(),
        viewOriginalPage: (context) => const ViewOriginalImagePageIOS()
      },
    );
  }

  void _initNotificationSettings() async {
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _selectNotification);
  }

  Future<dynamic> _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.pushNamed(context, '/');
            },
          )
        ],
      ),
    );
  }

  Future _selectNotification(String? payload) async {
    //Handle notification tapped logic here
  }
}
