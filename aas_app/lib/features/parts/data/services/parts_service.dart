import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../presentation/models/part.dart';

class PartsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get all parts
  static Future<List<Part>> getAllParts() async {
    try {
      final response = await _supabase
          .from('parts_inventory')
          .select()
          .order('part_name');

      final parts = (response as List).map((json) => Part.fromJson(json)).toList();
      
      // Debug: Print raw JSON for first part to see field names
      if (parts.isNotEmpty) {
        print('🔍 Raw JSON for first part:');
        print(response.first);
      }
      
      return parts;
    } catch (e) {
      throw Exception('Failed to fetch parts: $e');
    }
  }

  // Get part by ID
  static Future<Part> getPartById(int id) async {
    try {
      final response = await _supabase
          .from('parts_inventory')
          .select()
          .eq('id', id)
          .single();

      return Part.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch part: $e');
    }
  }

  // Upload part image
  static Future<String> uploadPartImage(File imageFile, String partName) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${partName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.jpg';
      final filePath = 'parts/$fileName';
      
      print('📤 Uploading image to: AAS/$filePath');
      
      await _supabase.storage
          .from('AAS')
          .upload(filePath, imageFile);
      
      final imageUrl = _supabase.storage
          .from('AAS')
          .getPublicUrl(filePath);
      
      print('✅ Image uploaded successfully. URL: $imageUrl');
      
      return imageUrl;
    } catch (e) {
      print('❌ Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Create new part
  static Future<Part> createPart(Part part, {File? imageFile}) async {
    try {
      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await uploadPartImage(imageFile, part.partName);
      }
      
      // Create part with image URL
      final partData = part.toJson();
      if (imageUrl != null) {
        partData['part_image_url'] = imageUrl;
      }
      
      final response = await _supabase
          .from('parts_inventory')
          .insert(partData)
          .select()
          .single();

      return Part.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create part: $e');
    }
  }

  // Update part
  static Future<Part> updatePart(Part part) async {
    try {
      if (part.id == null) {
        throw Exception('Part ID is required for update');
      }

      final response = await _supabase
          .from('parts_inventory')
          .update(part.toJson())
          .eq('id', part.id!)
          .select()
          .single();

      return Part.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update part: $e');
    }
  }

  // Delete part
  static Future<void> deletePart(int id) async {
    try {
      await _supabase
          .from('parts_inventory')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete part: $e');
    }
  }

  // Search parts by name
  static Future<List<Part>> searchParts(String searchTerm) async {
    try {
      final response = await _supabase
          .from('parts_inventory')
          .select()
          .ilike('part_name', '%$searchTerm%')
          .order('part_name');

      return (response as List).map((json) => Part.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search parts: $e');
    }
  }

  // Get parts by status
  static Future<List<Part>> getPartsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('parts_inventory')
          .select()
          .eq('part_status', status)
          .order('part_name');

      return (response as List).map((json) => Part.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch parts by status: $e');
    }
  }

  // Get parts by location
  static Future<List<Part>> getPartsByLocation(String location) async {
    try {
      final response = await _supabase
          .from('parts_inventory')
          .select()
          .ilike('part_location', '%$location%')
          .order('part_name');

      return (response as List).map((json) => Part.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch parts by location: $e');
    }
  }

  // Get parts statistics
  static Future<Map<String, dynamic>> getPartsStats() async {
    try {
      final allParts = await getAllParts();
      
      final totalParts = allParts.length;
      final activeParts = allParts.where((part) => part.isActive).length;
      final inactiveParts = totalParts - activeParts;
      
      // Group by location
      final locationGroups = <String, int>{};
      for (final part in allParts) {
        final location = part.displayLocation;
        locationGroups[location] = (locationGroups[location] ?? 0) + 1;
      }

      return {
        'totalParts': totalParts,
        'activeParts': activeParts,
        'inactiveParts': inactiveParts,
        'locationBreakdown': locationGroups,
      };
    } catch (e) {
      throw Exception('Failed to get parts statistics: $e');
    }
  }

  // Test method to create a part with a sample image URL
  static Future<Part> createTestPartWithImage() async {
    try {
      // Create a test part with a sample image URL
      final testPart = Part(
        partName: 'Test Part with Image',
        partDescription: 'This is a test part to verify image display',
        partNumber: 'TEST-001',
        partLocation: 'Test Shelf',
        partStatus: 'Active',
        partImageUrl: 'https://picsum.photos/300/300?random=1', // Sample image URL
      );

      final response = await _supabase
          .from('parts_inventory')
          .insert(testPart.toJson())
          .select()
          .single();

      print('✅ Test part created with image URL: ${testPart.partImageUrl}');
      return Part.fromJson(response);
    } catch (e) {
      print('❌ Failed to create test part: $e');
      throw Exception('Failed to create test part: $e');
    }
  }
}
