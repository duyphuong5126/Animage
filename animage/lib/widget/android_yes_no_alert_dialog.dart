import 'package:animage/constant.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:flutter/material.dart';

class YesNoConfirmationAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String yesLabel;
  final Function yesAction;
  final String noLabel;
  final Function noAction;

  const YesNoConfirmationAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.yesLabel,
    required this.noLabel,
    required this.yesAction,
    required this.noAction,
  }) : super(key: key);

  Color _getYesButtonColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected,
    };

    return states.any(interactiveStates.contains)
        ? accentColorDark
        : accentColor;
  }

  Color _getNoButtonColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected,
    };

    return states.any(interactiveStates.contains)
        ? accentColorLight
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Theme.of(context).dialogBackgroundColor,
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
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    yesAction();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith(_getYesButtonColor),
                    shape: MaterialStateProperty.resolveWith(
                      (states) => const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                  ),
                  child: Text(
                    yesLabel,
                    style: context.button?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    noAction();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith(_getNoButtonColor),
                    shape: MaterialStateProperty.resolveWith(
                      (states) => const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                  ),
                  child: Text(
                    noLabel,
                    style: context.button?.copyWith(color: accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
