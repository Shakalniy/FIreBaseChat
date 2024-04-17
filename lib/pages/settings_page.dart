import 'package:chat/app_exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ProfileService _profileService = ProfileService();
  AuthService _authService = AuthService();

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text (
              "Нет",
              style: TextStyle(
                fontFamily: "RobotoSlab"
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              deleteUser();
            },
            child: const Text (
              "Да",
              style: TextStyle(
                  fontFamily: "RobotoSlab"
              ),
            ),
          ),
        ],
        title: const Text(
          "Вы точно хотите удалить аккаунт ?",
          style: TextStyle(
              fontFamily: "RobotoSlab"
          ),
        ),
      ),
    );
  }

  void deleteUser() {
    try {
      var user = _authService.getCurrentUser();
      _profileService.deleteUser(user!);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AuthGate()
          )
      );
    }
    catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            e.toString(),
            style: const TextStyle(
                fontFamily: "RobotoSlab"
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ThemeProvider>(context, listen: false);
    var scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Настройки",
          style: TextStyles.styleOfAppBarText,
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 25,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //dark mode
                      Text(
                        "Тёмная тема",
                        style: TextStyles.styleOfSettingsItem,
                      ),

                      //switch toggle
                      CupertinoSwitch(
                          value: provider.isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              provider.toggleTheme();
                            });
                          }
                      ),
                    ]
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: scheme.onPrimaryContainer,
            child: GestureDetector(
              child: const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 20, top: 10),
                child: Text(
                  "Удалить пользователя",
                  style: TextStyle(
                    fontFamily: "RobotoSlab",
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
              onTap: () {
                confirmDelete();
              },
            ),
          ),
        ],
      ),
    );
  }
}