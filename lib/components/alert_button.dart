import 'package:flutter/material.dart';

import '../app_exports.dart';

class AlertButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool isLast;
  const AlertButton({
    super.key,
    required this.text,
    this.onTap,
    required this.isLast
  });

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                text,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyles.styleOfMainText,
              ),
            ),
          ),
        ),
        isLast
          ? Container()
          : Divider(height: 1, color: scheme.outline,),
      ],
    );
  }
}