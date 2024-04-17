import 'package:chat/app_exports.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey[300] as Color,
    primary: ColorsConst.primaryLight,
    outline: Colors.black26,
    primaryContainer: Colors.grey[200],
    secondary: Colors.black,
    scrim: Colors.white,
    onBackground: ColorsConst.backgroundColorChatPageLight,
    onSecondary: Colors.grey[200] as Color,
    onPrimary: Colors.green[100] as Color,
    onPrimaryContainer: Colors.grey[400] as Color,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: ColorsConst.primaryDark,
    outline: Colors.grey[500],
    primaryContainer: const Color.fromARGB(255, 61, 66, 69),
    secondary: Colors.white,
    scrim: Colors.black,
    onBackground: ColorsConst.backgroundColorChatPageDark,
    onSecondary: Colors.grey[800] as Color,
    onPrimary: Colors.green[900] as Color,
    onPrimaryContainer: Colors.grey[700] as Color,
  ),
);
