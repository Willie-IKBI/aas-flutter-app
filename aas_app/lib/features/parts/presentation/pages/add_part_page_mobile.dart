import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Mobile-specific implementation for AddPartPage platform interface
class AddPartPagePlatform {
  /// Get file from image picker result for mobile
  static dynamic getFileFromImage(XFile image) {
    // For mobile, we return a File object
    return File(image.path);
  }

  /// Build image widget for mobile
  static Widget buildImageWidget(dynamic image) {
    if (image is File) {
      return Image.file(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
    return const Center(
      child: Icon(Icons.error, color: Colors.red),
    );
  }
}
