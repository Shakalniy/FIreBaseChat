import 'dart:typed_data';

import 'package:flutter/material.dart';

class ViewPhotoPage extends StatelessWidget {

  final dynamic image;

  const ViewPhotoPage({
    super.key,
    required this.image
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          image is String
          ? Image(image: NetworkImage(image))
          : image is Uint8List ? Image(image: MemoryImage(image)) : Container(),
          const SizedBox(height: 50,),
        ],
      ),
    );
  }

}