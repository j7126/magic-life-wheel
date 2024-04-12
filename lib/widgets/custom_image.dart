import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.file,
  });

  final Uint8List file;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Center(
          child: Text('This image type is not supported'),
        );
      },
    );
  }
}
