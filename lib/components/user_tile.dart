import 'package:chat/app_exports.dart';
import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {

  final String name;
  final String otherUserId;
  final void Function()? onTap;
  final void Function()? onLongTap;

  const UserTile({
    super.key, 
    required this.name,
    required this.otherUserId,
    this.onTap,
    this.onLongTap,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? lastMessage;
  bool isLoading = true;
  String? _image;

  Future<void> getImageData() async {
    //String imageId = await _getImageId("imageId${widget.otherUserId}");
    List<Map<String, dynamic>> tempData = await _profileService.getProfileImages(widget.otherUserId);
    if (tempData.isNotEmpty) {
      Map<String, dynamic> data = tempData.last;
      setState(() {
        _image = data['imageLink'];
      });
    }
  }

  Future<void> getLastMessage(String otherUserId) async {
    await getImageData();
    String userId = _authService.getCurrentUser()!.uid;
    lastMessage = await _chatService.getLastMessage(userId, otherUserId);
    if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getLastMessage(widget.otherUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return isLoading ? const Padding(
      padding: EdgeInsets.all(5.0),
      child: Center(child: CircularProgressIndicator()),
    )
    : Column(
        children: [
          Container(
            color: scheme.primaryContainer,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: _image == null
                            ? const AssetImage("assets/images/avatar.jpg") as ImageProvider
                            : NetworkImage(_image!),
                        ),
                      ),
                      //user name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontFamily: "RobotoSlab",
                              fontSize: 16
                            ),
                          ),
                          Text(
                            lastMessage != null ? "${lastMessage!["senderName"]}: ${lastMessage!["message"]}"
                            : "Сообщений нет",
                            style: const TextStyle(
                                fontFamily: "RobotoSlab",
                                fontSize: 14
                            ),
                          ),
                        ],
                      ),
                    ]
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: scheme.outline, thickness: 2),
        ],
      );
  }
}