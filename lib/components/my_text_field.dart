import 'package:chat/app_exports.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  bool obscureText;
  final FocusNode? focusNode;
  final String typeOfField;
  final bool isCounter;
  final bool isEdit;
  final bool isChatField;
  final IconData? icon;
  final void Function()? onTap;
  final void Function()? onUploadFile;

  MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText, 
    this.focusNode,
    required this.typeOfField,
    required this.isCounter, 
    required this.isEdit, 
    required this.isChatField,
    this.icon,
    this.onTap,
    this.onUploadFile
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
  var scheme = Theme.of(context).colorScheme;
  Map<String, int> setMaxLength = {
    "namely": 40,
    "phoneNumber": 15,
    "status": 100,
    "message": 1000,
  };

  Map<String, int> setMaxLines = {
    "namely": 1,
    "phoneNumber": 1,
    "status": 5,
    "message": 5,
  };

    return TextField(
      autofocus: widget.isEdit,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.obscureText,
      maxLength: setMaxLength[widget.typeOfField] ?? 40,
      maxLines: setMaxLines[widget.typeOfField] ?? 1,
      minLines: 1,
      style: TextStyle(
        fontFamily: "RobotoSlabLight",
        color: scheme.secondary
      ),
      cursorColor: scheme.secondary,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorsConst.inputFocusedBorderColor),
          borderRadius: BorderRadius.circular(15),
        ),
        counterText: widget.isCounter ? null : "",
        fillColor: scheme.primaryContainer,
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontFamily: "RobotoSlabLight",
          color: scheme.secondary
        ),
        suffixIcon: (widget.isChatField) ?
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.attach_file_outlined,
                  color: scheme.primary,
                  size: 30,
                ),
                onPressed: widget.onUploadFile,
              ),
              IconButton(
                icon: Icon(
                  widget.icon,
                  color: scheme.primary,
                  size: 30,
                ),
                onPressed: widget.onTap,
              )
            ],
          )
          : null,
      ),
    );
  }
}