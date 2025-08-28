import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/order.dart';

class DocumentService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Upload document for an order
  static Future<String?> uploadOrderDocument({
    required int orderId,
    required String category,
    required String filename,
    required Uint8List fileBytes,
    required String mimeType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = filename.split('.').last;
      final storagePath = 'orders/$orderId/$category/${timestamp}_$filename';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from('documents')
          .uploadBinary(storagePath, fileBytes);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // Save document record to database
      final response = await _supabase
          .from('order_documents')
          .insert({
            'order_id': orderId,
            'category': category,
            'storage_path': storagePath,
            'filename': filename,
            'mime_type': mimeType,
            'uploaded_by': user.id,
            'meta': metadata ?? {},
          })
          .select()
          .single();

      return publicUrl;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  // Get documents for an order
  static Future<List<Map<String, dynamic>>> getOrderDocuments(int orderId) async {
    try {
      final response = await _supabase
          .from('order_documents')
          .select('''
            *,
            uploaded_by_user:profile!order_documents_uploaded_by_fkey(display_name, user_email)
          ''')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting order documents: $e');
      return [];
    }
  }

  // Delete document
  static Future<bool> deleteDocument(int documentId) async {
    try {
      // Get document info first
      final documentResponse = await _supabase
          .from('order_documents')
          .select('storage_path')
          .eq('id', documentId)
          .single();

      final storagePath = documentResponse['storage_path'] as String;

      // Delete from storage
      await _supabase.storage
          .from('documents')
          .remove([storagePath]);

      // Delete from database
      await _supabase
          .from('order_documents')
          .delete()
          .eq('id', documentId);

      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  // Pick file from device
  static Future<FilePickerResult?> pickFile({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // Get file size in human readable format
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Get file icon based on mime type
  static String getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return '🖼️';
    if (mimeType.startsWith('video/')) return '🎥';
    if (mimeType.startsWith('audio/')) return '🎵';
    if (mimeType.contains('pdf')) return '📄';
    if (mimeType.contains('word') || mimeType.contains('document')) return '📝';
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) return '📊';
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) return '📈';
    if (mimeType.contains('zip') || mimeType.contains('archive')) return '📦';
    return '📎';
  }

  // Validate file
  static bool isValidFile(PlatformFile file, {
    int? maxSizeBytes,
    List<String>? allowedExtensions,
  }) {
    // Check file size
    if (maxSizeBytes != null && file.size > maxSizeBytes) {
      return false;
    }

    // Check file extension
    if (allowedExtensions != null) {
      final extension = file.extension?.toLowerCase();
      if (extension == null || !allowedExtensions.contains(extension)) {
        return false;
      }
    }

    return true;
  }

  // Get validation error message
  static String? getValidationErrorMessage(PlatformFile file, {
    int? maxSizeBytes,
    List<String>? allowedExtensions,
  }) {
    if (maxSizeBytes != null && file.size > maxSizeBytes) {
      return 'File size exceeds ${getFileSize(maxSizeBytes)} limit';
    }

    if (allowedExtensions != null) {
      final extension = file.extension?.toLowerCase();
      if (extension == null || !allowedExtensions.contains(extension)) {
        return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
      }
    }

    return null;
  }

  // Download document
  static Future<Uint8List?> downloadDocument(String storagePath) async {
    try {
      final response = await _supabase.storage
          .from('documents')
          .download(storagePath);

      return response;
    } catch (e) {
      print('Error downloading document: $e');
      return null;
    }
  }

  // Get document categories
  static List<String> getDocumentCategories() {
    return [
      'invoice',
      'quotation',
      'work_order',
      'photos',
      'reports',
      'contracts',
      'warranty',
      'other',
    ];
  }

  // Get category display name
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'invoice':
        return 'Invoice';
      case 'quotation':
        return 'Quotation';
      case 'work_order':
        return 'Work Order';
      case 'photos':
        return 'Photos';
      case 'reports':
        return 'Reports';
      case 'contracts':
        return 'Contracts';
      case 'warranty':
        return 'Warranty';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}
