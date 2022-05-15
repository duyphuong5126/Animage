import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:flutter/cupertino.dart';

class RemovableChipIOS extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final String label;
  final bool allowRemoval;
  final Function onRemove;

  const RemovableChipIOS(
      {Key? key,
      required this.label,
      required this.bgColor,
      required this.textColor,
      required this.allowRemoval,
      required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: allowRemoval
          ? const EdgeInsets.only(left: 16.0, right: 8.0)
          : const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
          color: bgColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textStyle.copyWith(color: textColor),
          ),
          Visibility(
            child: CupertinoButton(
                minSize: 0,
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                child: const Icon(
                  CupertinoIcons.clear,
                  color: CupertinoColors.white,
                  size: 20.0,
                ),
                onPressed: () => onRemove()),
            visible: allowRemoval,
          )
        ],
      ),
    );
  }
}
