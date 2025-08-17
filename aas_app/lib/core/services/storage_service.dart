import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';

/// Storage Service
/// 
/// Handles file uploads, downloads, and management with Supabase Storage.
class StorageService {
  // Private constructor to prevent instantiation
  StorageService._();

  static const _uuid = Uuid();

  // ===== FILE UPLOAD METHODS =====

  /// Upload file to storage
  static Future<String> uploadFile({
    required String bucket,
    required String filePath,
    String? customPath,
    Map<String, String>? metadata,
  }) async {
    try {
      final file = File(filePath);
      final fileName = path.basename(filePath);
      final fileExtension = path.extension(fileName);
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
      final fileExtension = path.extension(fileName);
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
    required String filePath,
    required String category,
    Map<String, String>? metadata,
  }) async {
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(fileName);
    final uniqueFileName = '${_uuid.v4()}$fileExtension';
    
    final storagePath = 'orders/$orderId/$category/$uniqueFileName';

    return uploadFile(
      bucket: SupabaseConfig.orderFilesBucket,
      filePath: filePath,
      customPath: storagePath,
      metadata: metadata,
    );
  }

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
  }) async {
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(fileName);
    final uniqueFileName = '${_uuid.v4()}$fileExtension';
    
    final storagePath = 'profiles/$userId/$uniqueFileName';

    return uploadFile(
      bucket: SupabaseConfig.profileImagesBucket,
      filePath: filePath,
      customPath: storagePath,
    );
  }

  /// Upload part image
  static Future<String> uploadPartImage({
    required String partId,
    required String filePath,
  }) async {
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(fileName);
    final uniqueFileName = '${_uuid.v4()}$fileExtension';
    
    final storagePath = 'parts/$partId/$uniqueFileName';

    return uploadFile(
      bucket: SupabaseConfig.partImagesBucket,
      filePath: filePath,
      customPath: storagePath,
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
    int expiresIn = 3600, // 1 hour
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

  /// Delete multiple files from storage
  static Future<void> deleteFiles({
    required String bucket,
    required List<String> filePaths,
  }) async {
    try {
      await SupabaseConfig.storage
          .from(bucket)
          .remove(filePaths);

      if (kDebugMode) {
        print('✅ Files deleted successfully: ${filePaths.length} files');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Files deletion failed: $error');
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

  /// Get file size in bytes
  static Future<int> getFileSize({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final response = await SupabaseConfig.storage
          .from(bucket)
          .list(path: path.dirname(filePath));

      final file = response.firstWhere(
        (file) => file.name == path.basename(filePath),
      );

      return file.metadata['size'] ?? 0;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get file size failed: $error');
      }
      return 0;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await SupabaseConfig.storage
          .from(bucket)
          .list(path: path.dirname(filePath));

      return true;
    } catch (error) {
      return false;
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
          .list(path: path.dirname(filePath));

      final file = response.firstWhere(
        (file) => file.name == path.basename(filePath),
      );

      return file.metadata;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get file metadata failed: $error');
      }
      return null;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension from path
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Check if file is image
  static bool isImage(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  /// Check if file is video
  static bool isVideo(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm'].contains(extension);
  }

  /// Check if file is document
  static bool isDocument(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.pdf', '.doc', '.docx', '.txt', '.rtf'].contains(extension);
  }
}
