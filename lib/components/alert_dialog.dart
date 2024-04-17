import 'package:flutter/material.dart';

import '../app_exports.dart';

class MyAlertDialog extends StatelessWidget {

  final Map<String, void Function()> actions;
  final double? width;
  final Alignment? alignment;
  final Map<String, double>? margins;

  const MyAlertDialog({
    super.key,
    required this.actions,
    this.width,
    this.alignment,
    this.margins
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margins != null ? EdgeInsets.only(top: margins!["top"]!, bottom: margins!["bottom"]!, left: margins!["left"]!, right: margins!["right"]!) : null,
      alignment: alignment,
      child: SizedBox(
        width: width,
        child: AlertDialog(
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          alignment: alignment,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(var i = 0; i < actions.length; i++)
                AlertButton(
                  text: actions.keys.toList()[i],
                  onTap: actions[actions.keys.toList()[i]],
                  isLast: i == actions.length - 1 ? true : false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}