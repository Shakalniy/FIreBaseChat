import 'package:chat/app_exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String ids;
  final String senderName;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  //final bool isChecked;
  final bool isEditing;

  Message({
    required this.ids,
    required this.senderName,
    required this.senderId, 
    required this.senderEmail, 
    required this.receiverId, 
    required this.message,
    required this.timestamp,
    required this.isEditing,
  });

  // convert to map

  Map<String, dynamic> toMap() {
    return {
      'ids': ids,
      'senderName': senderName,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isEditing': isEditing,
    };
  }
}