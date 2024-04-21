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
  bool isLoading = true;
  List<Map<String, dynamic>> friendsData = [];

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

  Future<void> findUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchUser(),
      ),
    );
    if (result == "result") {
      setState(() {});
    }
  }

  Future<void> getUserData() async {
    final String userId = _authService.getCurrentUser()!.uid;
    var user = await ProfileService.getData(userId);
    var data = user!.data() as Map<String, dynamic>;
    List<String> friendsIds = (data["friends"] ?? []).cast<String>();
    List<Map<String,dynamic>> friendData = [];

    for (var id in friendsIds) {
      var friend = await ProfileService.getData(id);
      var data = friend!.data() as Map<String, dynamic>;
      friendData.add(data);
    }

    setState(() {
      friendsData = friendData;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Scaffold(body: Center(child: CircularProgressIndicator(),))
      : Scaffold(
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
                    "Найти пользователя": () async {
                      await findUser();
                    },
                  },
                  width: 200,
                  alignment: Alignment.topRight,
                  margins: const { "top": 50.0, "bottom": 0.0, "left": 0.0, "right": 20.0, },
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.more_vert_outlined)
          )
        ],
      ),
      drawer: const MyDrawer(),
      
      body: RefreshIndicator(
        onRefresh: getUserData,
        child: ListView(
          children: friendsData
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        ),
      ),
    );
  }

  // виджет отдельного пользователя в списке
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      name: userData["name"] ?? "Anonimus",
      otherUserId: userData["uid"],
      userData: userData,
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

}