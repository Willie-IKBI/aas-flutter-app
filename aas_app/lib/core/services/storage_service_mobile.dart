import 'dart:io';

/// Mobile-specific implementation for StorageService platform interface
class StorageServicePlatform {
  /// Get file name from mobile file object
  static String getFileName(dynamic file) {
    if (file is File) {
      return file.path.split('/').last;
    }
    return 'unknown_file';
  }
}
