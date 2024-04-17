import 'package:flutter/material.dart';

class ConfirmAlertDialog extends StatelessWidget {

  final String text;
  final void Function()? onConfirm;

  const ConfirmAlertDialog({
    super.key,
    required this.text,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        child: AlertDialog(
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "RobotoSlabMedium",
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Нет",
                  style: TextStyle(
                      color: scheme.secondary,
                      fontFamily: "RobotoSlab"
                  ),
                )
            ),
            TextButton(
                onPressed: onConfirm,
                child: Text(
                  "Да",
                  style: TextStyle(
                      color: scheme.secondary,
                      fontFamily: "RobotoSlab"
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}