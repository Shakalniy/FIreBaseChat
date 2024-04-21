import 'package:flutter/material.dart';

import '../app_exports.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _findedUsers = [];
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  Future<void> getUsers() async {
    final String userId = _authService.getCurrentUser()!.uid;
    int currentUserNum = -1;
    _chatService.getUsersStream().listen((list) {
      for (var i = 0; i < list.length; i++) {
        if (list[i]["uid"] == userId) {
          currentUserNum = i;
        }
      }
      list.removeAt(currentUserNum);
      setState(() {
        users = list;
        isLoading = false;
        _findedUsers = users;
      });
    });
  }

  void _searchUsers(){
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _findedUsers = users.where((user) {
        return (user["name"] ?? "Anonimus").toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    else {
      _findedUsers = users;
    }
    setState(() {});
  }

  @override
  void initState() {
    getUsers();
    _searchController.addListener(_searchUsers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Scaffold(body: Center(child: CircularProgressIndicator(),),)
      : Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          maxLines: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Поиск"
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, "result");
          },
        ),
      ),
      body: ListView(
        children: _findedUsers
            .map<Widget>((userData) => UserSearchTile(data: userData))
            .toList(),
      )
    );
  }
}