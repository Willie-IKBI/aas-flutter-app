/// Mobile implementation for StorageService platform interface
///
/// This implementation provides mobile-specific file operations
/// using the same interface as the web version.
class StorageServicePlatform {
  /// Get file name from mobile file object
  static String getFileName(dynamic file) {
    if (file != null) {
      // Try to get name property if it exists
      try {
        return file.name?.toString() ?? 'unknown_file';
      } catch (e) {
        // Fallback to path-based name extraction
        final path = file.path?.toString() ?? '';
        if (path.isNotEmpty) {
          return path.split('/').last.split(r'\').last;
        }
      }
    }
    return 'unknown_file';
  }

  /// Get file size from mobile file object
  static int getFileSize(dynamic file) {
    if (file != null) {
      try {
        return file.lengthSync() ?? 0;
      } catch (e) {
        // Fallback to size property if available
        return file.size ?? 0;
      }
    }
    return 0;
  }

  /// Check if file is valid for mobile
  static bool isValidFile(dynamic file) {
    return file != null;
  }
}
