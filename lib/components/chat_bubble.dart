import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';

import '../app_exports.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final String messageId;
  final String senderId;
  final String receiverId;
  final Color colorMessage;
  final List<double> marginMessage;
  final String time;
  final void Function()? onTap;
  final bool isEditing;

  const ChatBubble({
    super.key, 
    required this.message,
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.colorMessage, 
    required this.marginMessage,
    required this.time,
    this.onTap,
    required this.isEditing,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _images = [];
  bool isLoading = true;
  String message = "";

  Future<void> decryptText() async {
    String mes = await _chatService.decryptMessage(widget.message, widget.senderId, widget.receiverId);
    setState(() {
      message = mes;
    });
  }

  void getImages() async {
    await decryptText();
    _images = await _chatService.getMessageImages(widget.senderId, widget.receiverId, widget.messageId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : GestureDetector(
        onTap: () {
          widget.onTap!();
          // print("dfnbreuqifgewqoui");
          setState(() {
            getImages();
          });
        },
        //onHorizontalDragStart: (DragEndDetails) {print("dsfndj");},
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
          margin: EdgeInsets.only(left: widget.marginMessage[0], right: widget.marginMessage[1]),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.colorMessage
          ),
          child: Column(
            crossAxisAlignment: _images.isNotEmpty ? CrossAxisAlignment.end : CrossAxisAlignment.values[0],
            children: [
              message != ""
              ? Container(
                margin: _images.isEmpty ? const EdgeInsets.only(right: 25) : null,
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: "RobotoSlab",
                    fontSize: 16,
                  ),
                ),
              ) : const SizedBox(),

              for (var image in _images)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: GestureDetector(
                    child: SizedBox(
                      child: Image.network(image['imageLink']),
                    ),
                    onTap: () {
                      FullscreenImageViewer.open(
                        context: context,
                        child: ViewPhotoPage(image: image['imageLink'],),
                      );
                    },
                  ),
                ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.isEditing
                    ? const Text(
                      "изменено ",
                      style: TextStyle(
                        fontFamily: "RobotoSlab",
                        fontSize: 12,
                      ),
                    )
                    : Container(),
                  Text(
                    widget.time,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: "RobotoSlab",
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          )
        ),
      );
  }
}