import 'package:flutter/material.dart';

import '../colors.dart';
import '../constant.dart';

class LoadingBody extends StatelessWidget {
  const LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: Image.asset(
          "assets/gifs/ic_loading_cat_transparent.gif",
          height: loadingIconSize,
          width: loadingIconSize,
        ),
      ),
    );
  }
}
