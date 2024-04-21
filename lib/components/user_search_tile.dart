import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app_exports.dart';

class UserSearchTile extends StatefulWidget {
  const UserSearchTile({
    super.key,
    required this.data
  });
  final Map<String, dynamic> data;

  @override
  State<UserSearchTile> createState() => _UserSearchTileState();
}

class _UserSearchTileState extends State<UserSearchTile> {

  String? _image;
  final ProfileService _profileService = ProfileService();
  final ChatService _chatService = ChatService();

  Future<void> getImageData() async {
    List<Map<String, dynamic>> tempData = await _profileService.getProfileImages(widget.data["uid"]);
    if (tempData.isNotEmpty) {
      Map<String, dynamic> data = tempData.last;
      setState(() {
        _image = data['imageLink'];
      });
    }
  }

  void confirmInitChat(id, name) {
    showDialog(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        text: "Вы точно хотите создать чат с $name ?",
        onConfirm: () async {
          await createChatRoom(id, name);
          setState(() {});
        },
      ),
    );
  }


  Future<void> createChatRoom(id, name) async {
    Navigator.pop(context);
    String response = "";
    try{
      response = await _chatService.sendRequestToFriend(id);
    }
    catch(e) {
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
    finally {
      Fluttertoast.showToast(
        msg: response,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

  @override
  void initState() {
    getImageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        MaterialButton(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: _image == null
                  ? const AssetImage("assets/images/avatar.jpg") as ImageProvider
                  : NetworkImage(_image!),
                ),
              ),
              Text(
                widget.data["name"] ?? "Anonimus",
                style: const TextStyle(
                    fontFamily: "RobotoSlab",
                    fontSize: 16
                ),
              ),
            ],
          ),
          onPressed: () {
            confirmInitChat(widget.data["uid"], widget.data["name"] ?? "Anonimus");
          },
        ),
        Divider(height: 1, color: scheme.outline, thickness: 1),
      ],
    );
  }
}