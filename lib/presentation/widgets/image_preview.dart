import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    required this.filePath,
    this.height = 220,
    super.key,
  });

  final String filePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(filePath),
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const Text('Image unavailable'),
          );
        },
      ),
    );
  }
}
