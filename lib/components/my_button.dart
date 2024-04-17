import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const MyButton({
    super.key,
    this.onTap,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.scrim,
              fontSize: 20,
              fontFamily: "RobotoSlab",
            ),
          ),
        ),
      ),
    );
  }

}