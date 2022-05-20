import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:flutter/cupertino.dart';

class FavoritePageIOS extends StatefulWidget {
  const FavoritePageIOS({Key? key}) : super(key: key);

  @override
  State<FavoritePageIOS> createState() => _FavoritePageIOSState();
}

class _FavoritePageIOSState extends State<FavoritePageIOS> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Favorite',
        style: context.navTitleTextStyle,
      ),
    );
  }
}
