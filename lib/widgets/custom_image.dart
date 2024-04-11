import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.file,
  });

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(file.path),
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
