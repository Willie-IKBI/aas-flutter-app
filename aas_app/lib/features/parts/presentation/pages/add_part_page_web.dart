import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Web-specific implementation for AddPartPage platform interface
class AddPartPagePlatform {
  /// Get file from image picker result for web
  static dynamic getFileFromImage(XFile image) {
    // For web, we return the XFile directly
    return image;
  }

  /// Build image widget for web
  static Widget buildImageWidget(dynamic image) {
    if (image is XFile) {
      return Image.network(
        image.path,
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
