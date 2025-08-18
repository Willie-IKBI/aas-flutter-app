import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';

// Conditional imports for platform-specific functionality
import 'storage_service_web.dart' if (dart.library.io) 'storage_service_mobile.dart';

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

      await SupabaseConfig.storage
          .from(bucket)
          .upload(storagePath, file, fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
          ));

      final publicUrl = SupabaseConfig.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      if (kDebugMode) {
        print('✅ File uploaded successfully: $storagePath');
        print('📁 Public URL: $publicUrl');
      }

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {
        print('❌ File upload failed: $error');
      }
      rethrow;
    }
  }

  /// Upload bytes to storage
  static Future<String> uploadBytes({
    required String bucket,
    required Uint8List bytes,
    required String fileName,
    String? customPath,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileExtension = _getFileExtension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';
      
      final storagePath = customPath ?? uniqueFileName;

      await SupabaseConfig.storage
          .from(bucket)
          .upload(storagePath, bytes, fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
          ));

      final publicUrl = SupabaseConfig.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      if (kDebugMode) {
        print('✅ Bytes uploaded successfully: $storagePath');
        print('📁 Public URL: $publicUrl');
      }

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Bytes upload failed: $error');
      }
      rethrow;
    }
  }

  /// Upload order document
  static Future<String> uploadOrderDocument({
    required String orderId,
    required dynamic file,
    String? customPath,
  }) async {
    return uploadFile(
      bucket: SupabaseConfig.orderFilesBucket,
      file: file,
      customPath: customPath ?? 'orders/$orderId/${_uuid.v4()}',
    );
  }

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required String userId,
    required dynamic file,
    String? customPath,
  }) async {
    return uploadFile(
      bucket: SupabaseConfig.profileImagesBucket,
      file: file,
      customPath: customPath ?? 'profiles/$userId/${_uuid.v4()}',
    );
  }

  /// Upload part image
  static Future<String> uploadPartImage({
    required String partId,
    required dynamic file,
    String? customPath,
  }) async {
    return uploadFile(
      bucket: SupabaseConfig.partImagesBucket,
      file: file,
      customPath: customPath ?? 'parts/$partId/${_uuid.v4()}',
    );
  }

  // ===== FILE DOWNLOAD METHODS =====

  /// Download file from storage
  static Future<Uint8List> downloadFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final response = await SupabaseConfig.storage
          .from(bucket)
          .download(filePath);

      if (kDebugMode) {
        print('✅ File downloaded successfully: $filePath');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ File download failed: $error');
      }
      rethrow;
    }
  }

  /// Get public URL for file
  static String getPublicUrl({
    required String bucket,
    required String filePath,
  }) {
    return SupabaseConfig.storage
        .from(bucket)
        .getPublicUrl(filePath);
  }

  /// Get signed URL for file (with expiration)
  static Future<String> getSignedUrl({
    required String bucket,
    required String filePath,
    int expiresIn = 3600, // 1 hour default
  }) async {
    try {
      final response = await SupabaseConfig.storage
          .from(bucket)
          .createSignedUrl(filePath, expiresIn);

      if (kDebugMode) {
        print('✅ Signed URL created: $filePath');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Signed URL creation failed: $error');
      }
      rethrow;
    }
  }

  // ===== FILE MANAGEMENT METHODS =====

  /// List files in bucket
  static Future<List<FileObject>> listFiles({
    required String bucket,
    String? folder,
    int? limit,
    int? offset,
    String? sortBy,
  }) async {
    try {
      final response = await SupabaseConfig.storage
          .from(bucket)
          .list(
            path: folder,
            limit: limit,
            offset: offset,
            sortBy: sortBy != null ? SortBy(sortBy) : null,
          );

      if (kDebugMode) {
        print('✅ Files listed successfully: ${response.length} files');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ File listing failed: $error');
      }
      rethrow;
    }
  }

  /// Delete file from storage
  static Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await SupabaseConfig.storage
          .from(bucket)
          .remove([filePath]);

      if (kDebugMode) {
        print('✅ File deleted successfully: $filePath');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ File deletion failed: $error');
      }
      rethrow;
    }
  }

  /// Move file in storage
  static Future<void> moveFile({
    required String bucket,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await SupabaseConfig.storage
          .from(bucket)
          .move(fromPath, toPath);

      if (kDebugMode) {
        print('✅ File moved successfully: $fromPath -> $toPath');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ File move failed: $error');
      }
      rethrow;
    }
  }

  /// Copy file in storage
  static Future<void> copyFile({
    required String bucket,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await SupabaseConfig.storage
          .from(bucket)
          .copy(fromPath, toPath);

      if (kDebugMode) {
        print('✅ File copied successfully: $fromPath -> $toPath');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ File copy failed: $error');
      }
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
    return parts.length > 1 ? '.${parts.last}' : '';
  }

  /// Check if file exists
  static Future<bool> fileExists({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await SupabaseConfig.storage
          .from(bucket)
          .download(filePath);
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Get file size
  static Future<int> getFileSize({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final response = await SupabaseConfig.storage
          .from(bucket)
          .download(filePath);
      return response.length;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Could not get file size: $error');
      }
      return 0;
    }
  }

  /// Get file metadata
  static Future<Map<String, dynamic>?> getFileMetadata({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final response = await SupabaseConfig.storage
          .from(bucket)
          .list(path: filePath);
      
      if (response.isNotEmpty) {
        final file = response.first;
        return {
          'name': file.name,
          'size': file.metadata?['size'],
          'mimeType': file.metadata?['mimetype'],
          'lastModified': file.updatedAt,
        };
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Could not get file metadata: $error');
      }
      return null;
    }
  }
}
