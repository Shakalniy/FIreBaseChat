import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImage {
  final String id;
  final String imageLink;
  final Timestamp timestamp;

  ProfileImage ({
    required this.id,
    required this.imageLink,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "imageLink": imageLink,
      "timestamp": timestamp,
    };
  }
}