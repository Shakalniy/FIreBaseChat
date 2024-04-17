import 'dart:typed_data';
import 'package:chat/app_exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService extends ChangeNotifier {
  static final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ChatService _chatService = ChatService();

  Future<User> setProfile(String userName, String phoneNumber, String? status) async {
    try {
      User user = _firebaseAuth.currentUser!;

      _fireStore.collection("users").doc(user.uid).update({
        'name': userName,
        'phoneNumber': phoneNumber,
        'status': status,
      });

      return user;
    }
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> setImage(Uint8List file) async {
    try {
      User user = _firebaseAuth.currentUser!;

      final DocumentReference ref = _fireStore
          .collection('users')
          .doc(user.uid)
          .collection('profileImages')
          .doc();

      String id = ref.path.split("/").last;
      String imageUrl = await uploadImage('profileImage', file, id, user.uid);
      final Timestamp timestamp = Timestamp.now();

      ProfileImage newImage = ProfileImage(
        id: id,
        imageLink: imageUrl,
        timestamp: timestamp,
      );

      await ref.set(newImage.toMap());
    }
    catch(e) {
      throw Exception(e.toString());
    }
  }

  static Future<DocumentSnapshot?> getData(String userID) async {
    return await _fireStore.collection('users').doc(userID).get();
  }

  Future<List<Map<String, dynamic>>> getProfileImages(String userId) async {
    List<Map<String,dynamic>> images = [];

    await _fireStore
        .collection('users')
        .doc(userId)
        .collection('profileImages')
        .orderBy('timestamp', descending: false)
        .get().then((value) {
          for (var element in value.docs) {
            images.add(element.data());
          }
        });

    return images;
  }

  Future<void> deleteOneDialog(String firstUserId, secondUserId) async {
    List<String> ids = [firstUserId, secondUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    _fireStore.collection("chat_rooms").doc(chatRoomId).collection('messages')
        .get().then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String roomId = _chatService.getChatRoomId(data['senderId'], data['receiverId']);
            await _chatService.deleteMessage(roomId, data['ids']);
            doc.reference.delete();
          });
        });
    _fireStore.collection("chat_rooms").doc(chatRoomId).delete();
  }

  Future<void> deleteAllDialogs(User user) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> allUsers = await FirebaseFirestore.instance.collection("users").get();
      List list = [];
      for (var element in allUsers.docs) {
        var item = element.data()['uid'];
        if(item != user.uid) list.add(item);
      }
      for (var item in list) {
        deleteOneDialog(user.uid, item);
      }
    }
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> deleteUser(User user) async {
    try {
      await deleteAllDialogs(user);
      await _fireStore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if(file != null) {
      return file.readAsBytes();
    }
    else {
      return null;
    }
  }

  Future<String> uploadImage(String childName, Uint8List file, String id, userId) async {
    try {
      Reference ref = _firebaseStorage.ref().child(childName).child(userId).child(id);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }
    catch(e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteImage(String childName, imageId, userId) async {
    await _firebaseStorage
      .ref()
      .child(childName)
      .child(userId)
      .child(imageId)
      .delete();

    await _fireStore
      .collection('users')
      .doc(_firebaseAuth.currentUser!.uid)
      .collection('profileImages')
      .doc(imageId)
      .delete();
  }
}