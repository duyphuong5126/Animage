import 'package:animage/service/analytics_helper.dart';
import 'package:animage/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoriteCheckbox extends StatefulWidget {
  final double size;
  final Color color;
  final bool isFavorite;
  final Function(bool) onFavoriteChanged;

  const FavoriteCheckbox(
      {Key? key,
      required this.size,
      required this.color,
      required this.isFavorite,
      required this.onFavoriteChanged})
      : super(key: key);

  @override
  State<FavoriteCheckbox> createState() => _FavoriteCheckboxState();
}

class _FavoriteCheckboxState extends State<FavoriteCheckbox> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return isIOS
        ? CupertinoButton(
            padding: EdgeInsetsDirectional.zero,
            minSize: 0,
            child: Icon(
              _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              size: widget.size,
              color: widget.color,
            ),
            onPressed: () => setState(() {
                  _isFavorite = !_isFavorite;
                  widget.onFavoriteChanged(_isFavorite);
                }))
        : IconButton(
            padding: EdgeInsetsDirectional.zero,
            constraints: BoxConstraints.tightFor(
                width: widget.size + 4.0, height: widget.size + 4.0),
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_outline,
              size: widget.size,
              color: widget.color,
            ),
            onPressed: () => setState(() {
              _isFavorite = !_isFavorite;
              if (_isFavorite) {
                AnalyticsHelper.addFavorite();
              } else {
                AnalyticsHelper.removeFavorite();
              }
              widget.onFavoriteChanged(_isFavorite);
            }),
          );
  }
}
