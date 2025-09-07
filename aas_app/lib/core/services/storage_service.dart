import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';

// Conditional imports for platform-specific functionality
import 'storage_service_web.dart'
    if (dart.library.io) 'storage_service_mobile.dart';

/// Storage Service
///
/// Handles file uploads, downloads, and management with Supabase Storage.
/// Web-compatible with conditional imports for platform-specific functionality.
class StorageService {
  // Private constructor to prevent instantiation
  StorageService._();

  static const _uuid = Uuid();

  // ===== FILE UPLOAD METHODS =====

  /// Upload file to storage
  static Future<String> uploadFile({
    required String bucket,
    required dynamic file, // Can be File (mobile) or html.File (web)
    String? customPath,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = _getFileName(file);
      final fileExtension = _getFileExtension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';

      final storagePath = customPath ?? uniqueFileName;

      await SupabaseConfig.storage.from(bucket).upload(storagePath, file);

      final publicUrl =
          SupabaseConfig.storage.from(bucket).getPublicUrl(storagePath);

      if (kDebugMode) {}

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Upload bytes to storage
  static Future<String> uploadBytes({
    required String bucket,
    required List<int> bytes,
    required String fileName,
    String? customPath,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileExtension = _getFileExtension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';

      final storagePath = customPath ?? uniqueFileName;

      await SupabaseConfig.storage.from(bucket).upload(storagePath, bytes);

      final publicUrl =
          SupabaseConfig.storage.from(bucket).getPublicUrl(storagePath);

      if (kDebugMode) {}

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Upload order document
  static Future<String> uploadOrderDocument({
    required dynamic file,
    required String orderId,
    required String stage,
    required String category,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = _getFileName(file);
      final fileExtension = _getFileExtension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';

      final storagePath = 'orders/$orderId/$stage/$category/$uniqueFileName';

      final publicUrl = await uploadFile(
        bucket: SupabaseConfig.orderFilesBucket,
        file: file,
        customPath: storagePath,
        metadata: metadata,
      );

      if (kDebugMode) {}

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required dynamic file,
    required String userId,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = _getFileName(file);
      final fileExtension = _getFileExtension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';

      final storagePath = 'profiles/$userId/$uniqueFileName';

      final publicUrl = await uploadFile(
        bucket: SupabaseConfig.profileImagesBucket,
        file: file,
        customPath: storagePath,
        metadata: metadata,
      );

      if (kDebugMode) {}

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Upload part image
  static Future<String> uploadPartImage({
    required dynamic file,
    required String partId,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = _getFileName(file);
      final fileExtension = _getFileExtension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';

      final storagePath = 'parts/$partId/$uniqueFileName';

      final publicUrl = await uploadFile(
        bucket: SupabaseConfig.partImagesBucket,
        file: file,
        customPath: storagePath,
        metadata: metadata,
      );

      if (kDebugMode) {}

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  // ===== FILE DOWNLOAD METHODS =====

  /// Download file from storage
  static Future<List<int>> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await SupabaseConfig.storage.from(bucket).download(path);

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Get public URL for file
  static String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    try {
      final publicUrl = SupabaseConfig.storage.from(bucket).getPublicUrl(path);

      if (kDebugMode) {}

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  // ===== FILE MANAGEMENT METHODS =====

  /// Delete file from storage
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await SupabaseConfig.storage.from(bucket).remove([path]);

      if (kDebugMode) {}
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// List files in bucket
  static Future<List<Map<String, dynamic>>> listFiles({
    required String bucket,
    String? folder,
  }) async {
    try {
      final response =
          await SupabaseConfig.storage.from(bucket).list(path: folder ?? '');

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  // ===== UTILITY METHODS =====

  /// Get file name from file object
  static String _getFileName(dynamic file) {
    return StorageServicePlatform.getFileName(file);
  }

  /// Get file extension from file name
  static String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return '.${parts.last}';
    }
    return '';
  }

  /// Generate unique file name
  static String generateUniqueFileName(String originalName) {
    final extension = _getFileExtension(originalName);
    return '${_uuid.v4()}$extension';
  }

  /// Validate file size (max 10MB)
  static bool isValidFileSize(dynamic file) {
    // This would need to be implemented based on the file type
    // For now, return true as a placeholder
    return true;
  }

  /// Validate file type
  static bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = _getFileExtension(fileName).toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Get file size in bytes
  static Future<int> getFileSize({
    required String bucket,
    required String path,
  }) async {
    try {
      final response =
          await SupabaseConfig.storage.from(bucket).list(path: path);

      if (response.isNotEmpty) {
        return response.first['metadata']?['size'] ?? 0;
      }
      return 0;
    } catch (error) {
      if (kDebugMode) {}
      return 0;
    }
  }
}
