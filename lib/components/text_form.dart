import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../app_exports.dart';

class TextForm extends StatefulWidget {

  final TextEditingController controller;
  final TextEditingController? anotherController;
  final String hintText;
  String errorText;
  final bool isPassword;
  final void Function()? onTogglePassword;

  TextForm({
    super.key,
    required this.controller,
    this.anotherController,
    required this.hintText,
    required this.errorText,
    required this.isPassword,
    this.onTogglePassword,
  });

  @override
  State<TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> {
  bool isHiddenPassword = true;

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  bool validate(String? value) {
    if(widget.isPassword) {
      bool res = value != null && value.length < 6;
      if (!res && widget.anotherController != null) {
        widget.errorText = "Пароли не совпадают";
        res = res || (value != null && value != widget.anotherController!.text);
        return res;
      }
      widget.errorText = "Минимум 6 символов";
      return res;
    }
    return value != null && !EmailValidator.validate(value);
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;

    return TextFormField(
      keyboardType: widget.isPassword ? null : TextInputType.emailAddress,
      autocorrect: false,
      maxLength: 40,
      maxLines: 1,
      obscureText: isHiddenPassword && widget.isPassword,
      controller: widget.controller,
      style: TextStyle(
          fontFamily: "RobotoSlabLight",
          color: scheme.secondary
      ),
      cursorColor: scheme.secondary,
      validator: (value) => validate(value)
          ? widget.errorText
          : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorsConst.inputFocusedBorderColor),
          borderRadius: BorderRadius.circular(15),
        ),
        hintText: widget.hintText,
        fillColor: scheme.primaryContainer,
        filled: true,
        hintStyle: TextStyle(
            fontFamily: "RobotoSlabLight",
            color: scheme.secondary
        ),
        counterText: "",
        suffixIcon: widget.isPassword
         ? InkWell(
          onTap: togglePasswordView,
          child: Icon(
            isHiddenPassword
                ? Icons.visibility_off
                : Icons.visibility,
          ),
        )
        : null
      ),
    );
  }
}