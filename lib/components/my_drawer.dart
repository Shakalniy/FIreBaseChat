import 'package:chat/app_exports.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // выход пользователя из системы
  void signOut() {
    // получаем службу аутентификации
    final authService = AuthService();

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: scheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //logo
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.message,
                    color: scheme.primary,
                    size: 40,
                  ),
                )
              ),
              // home list tile
              ListTile(
                title: Text(
                  "Главная страница",
                  style: TextStyles.styleOfMainText,
                ),
                leading: const Icon(Icons.home),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              //settings list tile
              ListTile(
                title: Text(
                  "Настройки",
                  style: TextStyles.styleOfMainText,
                ),
                leading: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage()
                    )
                  );
                },
              ),
              ListTile(
                title: Text(
                  "Профиль",
                  style: TextStyles.styleOfMainText,
                ),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(isCurrentUser: true,)
                    )
                  );
                },
              ),
            ],
          ),

          //logiut list tile
          ListTile(
            title: Text(
              "Выход",
              style: TextStyles.styleOfMainText,
            ),
            leading: const Icon(Icons.logout),
            onTap: signOut,
          ),
        ]
      ),
    );
  }
}