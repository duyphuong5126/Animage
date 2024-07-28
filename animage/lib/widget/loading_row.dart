import 'package:flutter/widgets.dart';

import '../constant.dart';

class LoadingRow extends StatelessWidget {
  const LoadingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/gifs/ic_loading_cat_transparent.gif",
        height: smallLoadingIconSize,
        width: smallLoadingIconSize,
      ),
    );
  }
}
