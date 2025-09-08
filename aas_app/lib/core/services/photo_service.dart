import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_photo.dart';
import 'error_service.dart';

class PhotoService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Upload photo for an order
  static Future<OrderPhoto?> uploadOrderPhoto({
    required int orderId,
    required dynamic photoFile, // Can be File or PlatformFile
    String? photoName,
    String? photoDescription,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      Uint8List bytes;
      String fileName;

      // Handle different file types (web vs mobile)
      if (photoFile is File) {
        // Mobile platform
        bytes = await photoFile.readAsBytes();
        fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${photoFile.path.split('/').last}';
      } else if (photoFile is PlatformFile) {
        // Web platform
        bytes = photoFile.bytes!;
        fileName = '${DateTime.now().millisecondsSinceEpoch}_${photoFile.name}';
      } else if (photoFile is Uint8List) {
        // Handle case where photoFile might be Uint8List directly
        bytes = photoFile;
        fileName = '${DateTime.now().millisecondsSinceEpoch}_photo.jpg';
      } else {
        throw Exception('Unsupported file type: ${photoFile.runtimeType}');
      }

      // Compress and resize image
      final compressedBytes = await _compressImageBytes(bytes);

      // Upload to Supabase Storage with simple path (single-tenant app)
      final filePath = 'orders/$orderId/$fileName';

      // For web, we need to use uploadBinary for bytes
      await _supabase.storage
          .from('equipment-photos')
          .uploadBinary(filePath, compressedBytes);

      // Get public URL
      final photoUrl =
          _supabase.storage.from('equipment-photos').getPublicUrl(filePath);

      // Save photo record to database using order_documents table
      final response = await _supabase
          .from('order_documents')
          .insert({
            'order_id': orderId,
            'category': 'photo',
            'storage_path': filePath,
            'filename': photoName ?? fileName,
            'mime_type': 'image/jpeg', // Default to JPEG
            'uploaded_by': user.id,
            'meta': {
              'description': photoDescription,
              'original_filename': fileName,
            },
          })
          .select()
          .single();

      // Create OrderPhoto object with correct field mapping
      return OrderPhoto(
        id: response['id'].toString(),
        orderId: response['order_id'] as int,
        photoUrl: photoUrl,
        photoName: response['filename'] as String?,
        photoDescription: photoDescription,
        uploadedAt: DateTime.parse(response['created_at'] as String),
        uploadedBy: response['uploaded_by'] as String,
        uploaderName: 'Current User', // Will be populated when loading
      );
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PhotoService.uploadPhoto');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  // Get photos for an order
  static Future<List<OrderPhoto>> getOrderPhotos(int orderId) async {
    try {
      print('Loading photos for order $orderId...');
      
      // First, let's check if there are any documents for this order
      final allDocs = await _supabase
          .from('order_documents')
          .select('*')
          .eq('order_id', orderId);
      
      print('Found ${(allDocs as List).length} total documents for order $orderId');
      
      // Query order_documents table for photos
      final response = await _supabase
          .from('order_documents')
          .select('''
            id,
            order_id,
            storage_path,
            filename,
            uploaded_by,
            created_at,
            meta,
            category
          ''')
          .eq('order_id', orderId)
          .eq('category', 'photo')
          .order('created_at', ascending: false);

      print('Found ${(response as List).length} photos for order $orderId');

      // Convert the response to OrderPhoto objects
      return (response as List).map((doc) {
        print('Processing photo: ${doc['filename']} at ${doc['storage_path']}');
        
        // Get public URL from storage path
        final photoUrl = _supabase.storage
            .from('equipment-photos')
            .getPublicUrl(doc['storage_path']);

        // Extract description from meta field if available
        final meta = doc['meta'] as Map<String, dynamic>?;
        final description = meta?['description'] as String?;

        // Create OrderPhoto object with correct field mapping
        return OrderPhoto(
          id: doc['id'].toString(),
          orderId: doc['order_id'] as int,
          photoUrl: photoUrl,
          photoName: doc['filename'] as String?,
          photoDescription: description,
          uploadedAt: DateTime.parse(doc['created_at'] as String),
          uploadedBy: doc['uploaded_by'] as String,
          uploaderName: 'User', // Simplified for now
        );
      }).toList();
    } catch (e) {
      // Log the error for debugging
      ErrorService.logError(e, StackTrace.current, context: 'PhotoService.getOrderPhotos');
      print('Error loading photos for order $orderId: $e');
      return [];
    }
  }

  // Delete photo
  static Future<bool> deleteOrderPhoto(String photoId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Get photo details first
      final photoResponse = await _supabase
          .from('order_documents')
          .select('storage_path, uploaded_by')
          .eq('id', photoId)
          .eq('category', 'photo')
          .single();

      // Check if user can delete this photo
      if (photoResponse['uploaded_by'] != user.id) {
        throw Exception('Not authorized to delete this photo');
      }

      // Delete from storage
      final storagePath = photoResponse['storage_path'] as String;
      await _supabase.storage.from('equipment-photos').remove([storagePath]);

      // Delete from database
      await _supabase.from('order_documents').delete().eq('id', photoId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Pick image from gallery or camera
  static Future<dynamic> pickImage({
    bool allowMultiple = false,
    bool fromCamera = false,
  }) async {
    try {
      FilePickerResult? result;

      if (fromCamera) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: allowMultiple,
          withData: true,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: allowMultiple,
          withData: true, // Always get bytes for web compatibility
        );
      }

      if (result != null && result.files.isNotEmpty) {
        if (allowMultiple) {
          // Return list of files
          return result.files.map((file) {
            try {
              // Try to access path - if it fails, it's a web file
              if (file.path != null) {
                return File(file.path!); // File for mobile
              } else {
                return file; // PlatformFile for web
              }
            } catch (e) {
              // If accessing path throws an error, it's a web file
              return file; // PlatformFile for web
            }
          }).toList();
        } else {
          // Return single file
          final file = result.files.first;
          try {
            // Try to access path - if it fails, it's a web file
            if (file.path != null) {
              return File(file.path!); // File for mobile
            } else {
              return file; // PlatformFile for web
            }
          } catch (e) {
            // If accessing path throws an error, it's a web file
            return file; // PlatformFile for web
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Compress and resize image (bytes version)
  static Future<Uint8List> _compressImageBytes(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);

      if (image == null) return bytes;

      // Resize if too large (max 1920x1080)
      var resizedImage = image;
      if (image.width > 1920 || image.height > 1080) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1080 : null,
        );
      }

      // Compress (quality 85%)
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      return bytes; // Return original if compression fails
    }
  }

  // Compress and resize image (file version - for mobile)
  static Future<File> _compressImage(File file) async {
    try {
      // Read image
      final bytes = await file.readAsBytes();
      final compressedBytes = await _compressImageBytes(bytes);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      return file; // Return original if compression fails
    }
  }

  // Get photo count for an order
  static Future<int> getOrderPhotoCount(int orderId) async {
    try {
      final response = await _supabase
          .from('order_photos')
          .select('id')
          .eq('order_id', orderId);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Update photo details
  static Future<bool> updatePhotoDetails({
    required String photoId,
    String? photoName,
    String? photoDescription,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('order_photos')
          .update({
            if (photoName != null) 'photo_name': photoName,
            if (photoDescription != null) 'photo_description': photoDescription,
          })
          .eq('id', photoId)
          .eq('uploaded_by', user.id);

      return true;
    } catch (e) {
      return false;
    }
  }
}
