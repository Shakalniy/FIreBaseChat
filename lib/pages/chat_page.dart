import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';
import '../app_exports.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;

  const ChatPage({
    super.key, 
    required this.receiverUserName,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _messageRafactorController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isRefactor = false;
  Map<String, dynamic> currentMessageData = {};
  List<Uint8List> _images = [];
  List<Map<String, dynamic>> imagesInMessage = [];
  bool isLoading = true;
  String? _profileImage;
  List<dynamic> newImagesInMessage = [];
  List<Map<String, dynamic>> deletedImage = [];
  List<Uint8List> addingImage = [];

  // for textfield focus 
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    getImageData();
    super.initState();

    // добавляем слушателя к узлу фокусировки
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500), 
      () => scrollDown()
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // контроллер прокрутки
  final ScrollController _scrollController = ScrollController();
  void scrollDown () {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, 
      duration: const Duration(milliseconds: 500), 
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    // отправляем, только, если не пустое сообщение
    String message = _messageController.text;
    if(message.trim().isNotEmpty || _images.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, message, _images);

      setState(() {
        _messageController.clear(); // очищаем поле ввода после отправки
        _images = [];
      });
    }

    scrollDown();
  }

  void selectImage() async {
    try {
      Uint8List? img = await _chatService.pickImage(ImageSource.gallery);

      if (img != null) {
        setState(() {
          _images.add(img);
        });
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

  void addFile() async {
    try {
      Uint8List? img = await _chatService.pickImage(ImageSource.gallery);
      if (img != null) {
        setState(() {
          addingImage.add(img);
          newImagesInMessage.add(img);
        });
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

  void deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void deleteImageInMessage(int index) {
    setState(() {
      var image = newImagesInMessage.removeAt(index);
      if(addingImage.contains(image)) {
        addingImage.remove(image);
      }
      else {
        deletedImage.add(image);
      }
    });
  }

  Future<String> getName(String id) async {
    var user = await ProfileService.getData(id);
    var data = user!.data() as Map<String, dynamic>;
    return data['name'];
  }

  Future<void> refactorMessage(Map<String, dynamic> data) async {
    _messageRafactorController.text = data["message"];
    List<Map<String, dynamic>> imagesInMessage = await _chatService.getMessageImages(data["senderId"], data["receiverId"], data["ids"]);
    for (var element in imagesInMessage) {
      newImagesInMessage.add(element);
    }
    currentMessageData = data;
    if (context.mounted) {
      Navigator.pop(context);
    }
    setState(() {
      isRefactor = true;
    });
  }

  void sendChanges() async {
    String message = _messageRafactorController.text.trim();
    if (message.isNotEmpty || (newImagesInMessage.isNotEmpty)) {
      await _chatService.editMessage(
        currentMessageData,
        message,
        deletedImage,
        addingImage
      );
      setState(() {
        isRefactor = false;
        currentMessageData = {};
        _messageRafactorController.clear();
        newImagesInMessage = [];
        deletedImage = [];
        addingImage = [];
      });
    }
  }

  void confirmDeleteMessage(String idMessage) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        text: "Вы точно хотите удалить сообщение ?",
        onConfirm: () { deleteMessage(idMessage); },
      ),
    );
  }

  void deleteMessage(String idMessage) async {
    List<String> ids = [_firebaseAuth.currentUser!.uid, widget.receiverUserID];
    ids.sort();
    String roomId = ids.join("_");

    await _chatService.deleteMessage(roomId, idMessage);

    if(mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> onTapMessage(Map<String, dynamic> data, bool isOurMessage) async {
    await showDialog(
      context: context,
      builder: (context) => Container(
        alignment: Alignment.center,
          child: MyAlertDialog(
            actions: isOurMessage
            ? {
               "Редактировать": ()  { refactorMessage(data); },
               "Удалить": () { confirmDeleteMessage(data["ids"]); },
               "Скопировать сообщение": () { copyMessage(data["content"]); },
            }
            : {
              "Скопировать сообщение": () { copyMessage(data["content"]); }
            }
          ),
      )
    );
  }

  void copyMessage(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> getImageData() async {
    List<Map<String, dynamic>> tempData = await _profileService.getProfileImages(widget.receiverUserID);
    if (tempData.isNotEmpty) {
      Map<String, dynamic> data = tempData.last;
      _profileImage = data['imageLink'];
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return isLoading ? const Center(child: CircularProgressIndicator(),)
    : Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: _profileImage == null
                      ? const AssetImage("assets/images/avatar.jpg") as ImageProvider
                      : NetworkImage(_profileImage!),
                ),
              ),
              Text(
                widget.receiverUserName,
                style: const TextStyle(
                  fontFamily: "RobotoSlabMedium",
                  fontSize: 18,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(isCurrentUser: false, otherUserId: widget.receiverUserID,)
                )
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, "result");
          },
        ),
        titleSpacing: -5,
      ),
      backgroundColor: scheme.onBackground,
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          isRefactor ?
            _buildRefactorMessageInput() :
            _buildMessageInput(),

          const SizedBox(height: 5,)
        ]
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Ошибка ${snapshot.error.toString()}",
              style: TextStyles.styleOfErrorText,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      }
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    var scheme = Theme.of(context).colorScheme;

    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //print(data);

    // расположение сообщений, ваши справа, собеседника слева
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? Alignment.centerRight
      : Alignment.centerLeft;
    var crossAlignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? CrossAxisAlignment.end
      : CrossAxisAlignment.start;
    var mainAlignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? MainAxisAlignment.end
      : MainAxisAlignment.start;

    var colorMessage = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? scheme.onPrimary
      : scheme.onSecondary;

    var marginMessage = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? [30.0, 0.0]
      : [0.0, 30.0];
    DateTime date = data['timestamp'].toDate();
    String time = "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
    bool isOurMessage = data['senderId'] == _firebaseAuth.currentUser!.uid;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: crossAlignment,
          mainAxisAlignment: mainAlignment,
          children: [
            Text(data['senderName'] ?? data['senderEmail']),
            const SizedBox(height: 5,),
            ChatBubble(
              message: data['message'],
              messageId: data['ids'],
              senderId: data['senderId'],
              receiverId: data['receiverId'],
              colorMessage: colorMessage,
              marginMessage: marginMessage,
              time: time,
              onTap: () async {
                await onTapMessage(data, isOurMessage);
                // print("dniweqvbefhui");
              },
              isEditing: data["isEditing"] ?? false
            ),
          ],
        ),
      ),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    var scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: _images.isNotEmpty ? scheme.onPrimaryContainer : Colors.transparent,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _images.isNotEmpty ? SizedBox(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(var i = 0; i < _images.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Stack(
                            children: [
                              GestureDetector(
                                child: Image(
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  image: MemoryImage(_images[i]),
                                ),
                                onTap: () {
                                  FullscreenImageViewer.open(
                                    context: context,
                                    child: ViewPhotoPage(image: _images[i],),
                                  );
                                },
                              ),
                              Positioned(
                                top: -15,
                                left: 27,
                                child: IconButton(
                                  onPressed: () { deleteImage(i); },
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
            : Container(),
            MyTextField(
              controller: _messageController,
              hintText: 'Введите сообщение',
              obscureText: false,
              focusNode: myFocusNode,
              typeOfField: "message",
              isCounter: false,
              isEdit: false,
              // send button
              isChatField: true,
              icon: Icons.send,
              onTap: sendMessage,
              onUploadFile: selectImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefactorMessageInput() {
    var scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            color: scheme.onBackground,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Редактирование",
                  style: TextStyle(
                    fontFamily: "RobotoSlabLight",
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMessageData = {};
                      _messageRafactorController.clear();
                      newImagesInMessage = [];
                      deletedImage = [];
                      addingImage = [];
                      isRefactor = false;
                    });
                  },
                  icon: const Icon(Icons.close_outlined)
                ),
              ],
            ),
          ),
          newImagesInMessage.isNotEmpty ? SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(var i = 0; i < newImagesInMessage.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Stack(
                          children: [
                            GestureDetector(
                              child: Image(
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                image: newImagesInMessage[i].runtimeType.toString() == "Uint8List"
                                  ? MemoryImage(newImagesInMessage[i]) as ImageProvider
                                  : NetworkImage(newImagesInMessage[i]["imageLink"])
                              ),
                              onTap: () {
                                FullscreenImageViewer.open(
                                  context: context,
                                  child: ViewPhotoPage(image: newImagesInMessage[i],),
                                );
                              },
                            ),
                            Positioned(
                              top: -15,
                              left: 27,
                              child: IconButton(
                                onPressed: () { deleteImageInMessage(i); },
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ) : const SizedBox(),
          MyTextField(
            controller: _messageRafactorController, 
            hintText: 'Введите сообщение', 
            obscureText: false,
            typeOfField: "message",
            isCounter: false,
            isEdit: true,
            isChatField: true,
            icon: Icons.edit,
            onTap: sendChanges,
            onUploadFile: addFile,
          ),
        ],
      ),
    );
  }
}