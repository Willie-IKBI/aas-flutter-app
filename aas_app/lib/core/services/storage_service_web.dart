import 'dart:html' as html;

/// Web-specific implementation for StorageService platform interface
class StorageServicePlatform {
  /// Get file name from web file object
  static String getFileName(dynamic file) {
    if (file is html.File) {
      return file.name;
    }
    return 'unknown_file';
  }
}
