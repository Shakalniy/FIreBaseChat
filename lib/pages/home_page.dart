import 'package:flutter/material.dart';

import '../app_exports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  void confirmDeleteAllDialogs() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        text: "Вы точно хотите удалить все свои диалоги ?",
        onConfirm: () async {
          await deleteAllDialogs();
          setState(() {});
        },
      ),
    );
  }

  Future<void> deleteAllDialogs() async {
    try {
      await _profileService.deleteAllDialogs(_authService.getCurrentUser()!);
      if(mounted) {
        Navigator.pop(context);
      }
    }
    catch(e) {
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

  void confirmDeleteOneDialog(String firstUserId, secondUserId, name) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        text: "Вы точно хотите очистить диалог с $name ?",
        onConfirm: () async {
          await deleteOneDialog(firstUserId, secondUserId);
          setState(() {});
        },
      ),
    );
  }

  Future<void> deleteOneDialog(String firstUserId, secondUserId) async {
    try {
      await _profileService.deleteOneDialog(firstUserId, secondUserId);
      if(mounted) {
        Navigator.pop(context);
      }
    }
    catch(e) {
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
  Widget build(BuildContext context) {return Scaffold(
      appBar: AppBar(
        title: Text(
          "Главная страница",
          style: TextStyles.styleOfAppBarText,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => MyAlertDialog(
                  actions: {
                    "Очистить все диалоги": () {
                      confirmDeleteAllDialogs();
                      setState(() {});
                    },
                    "Другая функция": () {},
                  },
                  width: 200,
                  alignment: Alignment.topRight,
                  margins: const { "top": 50.0, "bottom": 0.0, "left": 0.0, "right": 20.0, },
                ),
              );
            },
            icon: const Icon(Icons.more_vert_outlined)
          )
        ],
      ),
      drawer: const MyDrawer(),
      
      body: _buildUserList(),
    );
  }

  // список пользователей, кроме текущего
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Ошибка",
              style: TextStyles.styleOfErrorText
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()
          );
        }

        return ListView(
          children: snapshot.data!
            .map<Widget>((userData) => _buildUserListItem(userData, context))
            .toList(),
        );
      }
    );
  }

  // виджет отдельного пользователя в списке
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {

    // показываем всех пользователей кроме текущего
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        name: userData["name"] ?? "Anonimus",
        otherUserId: userData["uid"],
        onTap: () async {
          // переход в чат
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserName: userData['name'] ?? userData["email"],
                receiverUserID: userData['uid'],
              ),
            ),
          );
          if (result == "result") {
            setState(() {});
          }
        },
        onLongTap: () {
          showDialog(
            context: context,
            builder: (context) => MyAlertDialog(
              actions: {
                "Очистить диалог (${userData["name"] ?? "Anonimus"})": () {
                  confirmDeleteOneDialog(_authService.getCurrentUser()!.uid, userData["uid"], userData["name"] ?? "Anonimus");
                  setState(() {});
                },
                "Другая функция": () {},
              },
              margins: const { "top": 0, "bottom": 0, "left": 20, "right": 20, },
            )
          );
        },
      );
    }
    else {
      return Container();
    }
  }

}