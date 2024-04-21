import 'package:flutter/material.dart';

import '../app_exports.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({super.key});

  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {

  bool isLoading = true;
  List<Map<String, dynamic>> potentialFriendsData = [];
  final AuthService _authService = AuthService();

  Future<void> getUserData() async {
    final String userId = _authService.getCurrentUser()!.uid;
    var user = await ProfileService.getData(userId);
    var data = user!.data() as Map<String, dynamic>;
    List<String> friendsIds = data["potential_friends"].cast<String>();
    List<Map<String,dynamic>> friendData = [];

    for (var id in friendsIds) {
      var friend = await ProfileService.getData(id);
      var data = friend!.data() as Map<String, dynamic>;
      friendData.add(data);
    }

    setState(() {
      potentialFriendsData = friendData;
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
    return isLoading ? const Scaffold(body: Center(child: CircularProgressIndicator(),),)
      : Scaffold(
      appBar: AppBar(
        title: Text(
          "Заявки в друзья",
          style: TextStyles.styleOfAppBarText,
        ),
        elevation: 0,
      ),
      body: ListView(
        children: potentialFriendsData
            .map<Widget>((userData) => AddUserTile(data: userData))
            .toList(),
      ),
    );
  }
}