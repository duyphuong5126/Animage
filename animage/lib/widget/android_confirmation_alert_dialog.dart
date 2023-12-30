import 'package:animage/constant.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:flutter/material.dart';

class AndroidConfirmationAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final Function confirmAction;

  const AndroidConfirmationAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.confirmAction,
  }) : super(key: key);

  Color _getBackgroundColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected,
    };

    return states.any(interactiveStates.contains)
        ? accentColorDark
        : accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: context.theme.dialogBackgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            maxLines: 10,
            textAlign: TextAlign.center,
            text: TextSpan(text: title, style: context.headline6),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(20),
        ),
      ),
      content: RichText(
        maxLines: 10,
        textAlign: TextAlign.center,
        text: TextSpan(text: content, style: context.bodyText1),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          constraints: const BoxConstraints.expand(height: 40),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              confirmAction();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith(_getBackgroundColor),
              shape: MaterialStateProperty.resolveWith(
                (states) => const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            ),
            child: Text(
              confirmLabel,
              style: context.button?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
