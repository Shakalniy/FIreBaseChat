import 'dart:typed_data';
import 'package:chat/app_exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatService {
  // экземпляр класса auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // SEND MESSAGE
  Future<void> sendMessage(String receiverId, message, List<Uint8List> images) async { //Map<String, dynamic>
    try {
      // получить информацию от текущем пользователе
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      var allData = await ProfileService.getData(currentUserId);
      Map<String, dynamic> data = allData!.data() as Map<String, dynamic>;
      final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
      final String currentUserName = data["name"] ?? currentUserEmail;
      final Timestamp timestamp = Timestamp.now();

      // создать ид чата для текущего пользователя и ид получателя
      String chatRoomId = getChatRoomId(currentUserId, receiverId);

      final DocumentReference ref = _fireStore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      var id = ref.path.split("/").last;

      for (var image in images) {
        await uploadImageInMessage(chatRoomId, id, image);
      }

      // создание нового сообщения
      Message newMessage = Message(
        ids: id,
        senderName: currentUserName,
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
        isEditing: false,
        //typeOfMessage: typeOfMessage
      );

      await ref.set(newMessage.toMap());
    }
    on FirebaseException catch (e) {
      throw Exception(e.code);
    }
  }

  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _fireStore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // просмотреть каждого отдельного пользователя
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // GET MESSAGE
  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    // получить ид комнаты чата
    String chatRoomId = getChatRoomId(userId, otherUserId);

    return _fireStore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
  }

  Future<List<Map<String, dynamic>>> getMessageImages(String userId, otherUserId, messageId) async {
    String chatRoomId = getChatRoomId(userId, otherUserId);
    List<Map<String,dynamic>> images = [];

    await _fireStore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .doc(messageId)
      .collection('images')
      .get().then((value) {
        for (var element in value.docs) {
          images.add(element.data());
        }
      });

    //print(images);
    return images;
  }

  Future<Map<String, dynamic>?> getLastMessage(String userId, otherUserId) async {
    String chatRoomId = getChatRoomId(userId, otherUserId);

    Map<String, dynamic>? message;
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages').orderBy('timestamp', descending: false).get().then((value) {
          if(value.docs.isNotEmpty) {
            message = value.docs.last.data();
          }
          else {
            message = null;
          }
    });
    return message;
  }

  String getChatRoomId(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    return ids.join("_");
  }

  Future<void> deleteMessage(String roomId, idMessage) async {
    _fireStore.collection('chat_rooms').doc(roomId).collection('messages').doc(idMessage).collection('images')
        .get().then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            deleteImage(roomId, idMessage, data['id']);
          }
    });
    _fireStore.collection('chat_rooms').doc(roomId).collection('messages').doc(idMessage).delete();
  }

  Future<void> editMessage(Map<String, dynamic> messageData, String newText, List<Map<String, dynamic>> deletedImage, List<Uint8List> addingImage) async {
    String senderId = messageData["senderId"];
    String receiverId = messageData["receiverId"];
    String messageId = messageData["ids"];
    String chatRoomId = getChatRoomId(senderId, receiverId);

    for (var image in deletedImage) {
      deleteImage(chatRoomId, messageId, image["id"]);
    }

    for (var image in addingImage) {
      uploadImageInMessage(chatRoomId, messageId, image);
    }

    messageData["isEditing"] = true;
    messageData["message"] = newText;

    _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update(messageData);
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

  Future<void> uploadImageInMessage(String chatRoomId, messageId, Uint8List image) async {
    final DocumentReference imageRef = _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .collection('images')
        .doc();
    var imageId = imageRef.path.split("/").last;
    String imageLink = await uploadImage(chatRoomId, image, imageId);

    MessageImage newImage = MessageImage(
      id: imageId,
      imageLink: imageLink,
    );

    await imageRef.set(newImage.toMap());
  }

  Future<String> uploadImage(String childName, Uint8List file, String id) async {
    try {
      Reference ref = _firebaseStorage.ref().child(childName).child(id);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }
    catch(e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteImage(String childName, messageId, imageId) async {
    await _firebaseStorage
        .ref()
        .child(childName)
        .child(imageId)
        .delete();

    await _fireStore
        .collection('chat_rooms')
        .doc(childName)
        .collection('messages')
        .doc(messageId)
        .collection('images')
        .doc(imageId)
        .delete();
  }
}