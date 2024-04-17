import 'package:flutter/material.dart';

class TextStyles {

  static TextStyle styleOfMainText = 
    const TextStyle(
      fontSize: 16,
      fontFamily: "RobotoSlabMedium",
    );

  static TextStyle styleOfAppBarText = 
    const TextStyle (
      fontFamily: "RobotoSlabMedium",
    );

  static TextStyle styleOfErrorText = 
    const TextStyle (
      fontFamily: "RobotoSlabMedium",
      fontSize: 20,
      color: Colors.black
    );

  static TextStyle styleOfSettingsItem = 
    const TextStyle(
      fontFamily: "RobotoSlab",
      fontSize: 18,
      fontWeight: FontWeight.bold
    );
}