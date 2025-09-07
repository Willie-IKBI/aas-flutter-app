/// IO implementation for StorageService platform interface
///
/// This implementation provides mobile/desktop specific file operations
/// since these platforms don't have web-specific file handling.
class StorageServicePlatform {
  /// Get file name from mobile/desktop file object
  static String getFileName(dynamic file) {
    // For mobile/desktop, file objects typically have a name property
    // or we can extract it from the path
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

  /// Get file size from mobile/desktop file object
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

  /// Check if file is valid for mobile/desktop
  static bool isValidFile(dynamic file) {
    return file != null;
  }
}
