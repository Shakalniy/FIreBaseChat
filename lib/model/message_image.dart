class MessageImage {
  final String id;
  final String imageLink;

  MessageImage({
    required this.id,
    required this.imageLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageLink': imageLink,
    };
  }
}