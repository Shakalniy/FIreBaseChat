import 'package:flutter/material.dart';
import '../app_exports.dart';

class AddUserTile extends StatefulWidget {
  const AddUserTile({
    super.key,
    required this.data
  });

  final Map<String, dynamic> data;

  @override
  State<AddUserTile> createState() => _AddUserTileState();
}

class _AddUserTileState extends State<AddUserTile> {

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

  Future<void> rejectFriend() async {
    //
  }

  Future<void> addFriend(id) async {
    Navigator.pop(context);
    try {
      _chatService.addFriend(id);
    }
    catch (e) {
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
      Navigator.pop(context);
    }
  }

  void confirmAddFriend(id, name) {
    showDialog(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        text: "Вы точно хотите дружить с $name ?",
        onConfirm: () async {
          await addFriend(id);
          setState(() {});
        },
        onReject: () async {
          await rejectFriend();
          setState(() {});
        },
      ),
    );
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row (
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
              ]
            ),
            IconButton(
              onPressed: () {
                confirmAddFriend(widget.data["uid"], widget.data["name"] ?? "Anonimus");
              },
              icon: const Icon(Icons.person_add)
            )
          ],
        ),
        Divider(height: 1, color: scheme.outline, thickness: 1),
      ],
    );
  }
}