import 'package:chat/app_exports.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {

  late ThemeData _themeData;
  String _theme = "light";

  ThemeData get themeData {
    _getTheme("theme").then((value) => _theme = value);
    _themeData = _theme == "dark" ? darkMode : lightMode;
    return _themeData;
  }

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  Future _setTheme(String theme, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, theme);
  }

  Future<String> _getTheme(String key) async {
    var prefs = await SharedPreferences.getInstance();
    _theme = prefs.getString(key) ?? "";
    return _theme;
  }

  void toggleTheme() async {
    if (_themeData == lightMode) {
      _theme = "dark";
      await _setTheme(_theme, "theme");
      themeData = darkMode;
    }
    else {
      _theme = "light";
      await _setTheme(_theme, "theme");
      themeData = lightMode;
    }
  }
}