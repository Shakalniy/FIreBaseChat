import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';
import 'package:image_picker/image_picker.dart';
import '../app_exports.dart';

class ProfilePage extends StatefulWidget {
  final bool isCurrentUser;
  final String? otherUserId;

  const ProfilePage({
    super.key,
    required this.isCurrentUser,
    this.otherUserId
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic> data = {};
  Map<String, dynamic> imageData = {};
  bool isLoading = true;
  String? _imageId;
  String? _image;

  Future<void> getData(String? userId) async {
    userId ??= _authService.getCurrentUser()!.uid;
    var tempData = await ProfileService.getData(userId);
    if(tempData != null) {
      data = tempData.data() as Map<String, dynamic>;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getImageData(String? userId) async {
    userId ??= _authService.getCurrentUser()!.uid;
    var tempImageData = await _profileService.getProfileImages(userId);
    if(tempImageData.isNotEmpty) {
      imageData = tempImageData.last;
      _imageId = imageData["id"];
      _image = imageData['imageLink'];
    }
    else {
      imageData = {};
      _imageId = "";
      _image = "";
    }
    setState(() {
      isLoading = false;
    });
  }

  void selectImage() async {
    try {
      Uint8List? img = await _profileService.pickImage(ImageSource.gallery);
      if (img != null) {
        await _profileService.setImage(img);
        String userId = _authService.getCurrentUser()!.uid;
        await getImageData(userId);
        setState(() {});
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

  void confirmDeleteImage(String imageLink) {
    showDialog(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        text: "Вы точно хотите удалить свою аватарку ?",
        onConfirm: () async {
          String userId = _authService.getCurrentUser()!.uid;
          await deleteImage(userId);
          setState(() {
            getImageData(userId);
          });
        },
      ),
    );
  }

  Future<void> deleteImage(String userId) async {
    try {
      await _profileService.deleteImage('profileImage', _imageId, userId);
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
  void initState() {
    getData(widget.otherUserId);
    getImageData(widget.otherUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text (
          "Профиль",
          style: TextStyles.styleOfAppBarText,
        ),
        actions: [
          widget.isCurrentUser ?
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeProfilePage(
                    name: data['name'] ?? "",
                    phoneNumber: data['phoneNumber'] ?? "",
                    status: data['status'] ?? "",
                  )
                )
              );
              await getData(null);
            },
            icon: const Icon(Icons.edit)
          )
          : const SizedBox(),
        ],
      ),
      body: isLoading
      ? const Center (
        child: CircularProgressIndicator(),
      )
      : SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50,),

              Stack(
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      radius: 64,
                      backgroundImage: _image != null && _image!.isNotEmpty
                      ? NetworkImage(_image!)
                      : const AssetImage("assets/images/avatar.jpg") as ImageProvider,
                    ),
                    onTap: () {
                      if(_image != null) {
                        FullscreenImageViewer.open(
                          context: context,
                          child: ViewPhotoPage(image: _image!,),
                        );
                      }
                    },
                  ),
                  widget.isCurrentUser ?
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                  : const SizedBox(),
                  widget.isCurrentUser && _image != null && _image!.isNotEmpty ?
                  Positioned(
                    bottom: 90,
                    left: 82,
                    child: IconButton(
                      onPressed: () { confirmDeleteImage(_image!); } ,
                      icon: const Icon(Icons.delete, color: Colors.redAccent,),
                    ),
                  )
                  : const SizedBox(),
                ],
              ),

              const SizedBox(height: 25,),

              Text(
                "Имя: ${data["name"] == null || data["name"].toString().isEmpty ? "Не задано" : data["name"]}",
              ),

              const SizedBox(height: 25,),

              Text(
                "Почта: ${data["email"] == null || data["email"].toString().isEmpty ? "Не задано" : data["email"]}",
              ),

              const SizedBox(height: 25,),

              Text(
                "Номер телефона: ${data["phoneNumber"] == null || data["phoneNumber"].toString().isEmpty ? "Не задано" : data["phoneNumber"]}",
              ),

              const SizedBox(height: 25,),

              Text(
                "Статус: ${data["status"] == null || data["status"].toString().isEmpty ? "Не задано" : data["status"]}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}