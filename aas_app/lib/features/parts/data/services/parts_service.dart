import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../presentation/models/part.dart';

/// Parts Service
/// 
/// Handles all parts-related operations with Supabase.
class PartsService {
  // Private constructor to prevent instantiation
  PartsService._();

  // ===== CRUD OPERATIONS =====

  /// Get all parts
  static Future<List<Part>> getAllParts() async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .order('created_at', ascending: false);

      final parts = response.map((json) => Part.fromJson(json)).toList();

      if (kDebugMode) {
        print('✅ Retrieved ${parts.length} parts');
      }

      return parts;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get parts: $error');
      }
      rethrow;
    }
  }

  /// Get part by ID
  static Future<Part?> getPartById(int partId) async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .eq('id', partId)
          .single();

      final part = Part.fromJson(response);

      if (kDebugMode) {
        print('✅ Retrieved part: ${part.partName}');
      }

      return part;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get part: $error');
      }
      return null;
    }
  }

  /// Create new part
  static Future<Part> createPart(Part part) async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .insert(part.toJson())
          .select()
          .single();

      final createdPart = Part.fromJson(response);

      if (kDebugMode) {
        print('✅ Created part: ${createdPart.partName}');
      }

      return createdPart;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to create part: $error');
      }
      rethrow;
    }
  }

  /// Update part
  static Future<Part> updatePart(Part part) async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .update(part.toJson())
          .eq('id', part.id!)
          .select()
          .single();

      final updatedPart = Part.fromJson(response);

      if (kDebugMode) {
        print('✅ Updated part: ${updatedPart.partName}');
      }

      return updatedPart;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to update part: $error');
      }
      rethrow;
    }
  }

  /// Delete part
  static Future<void> deletePart(int partId) async {
    try {
      await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .delete()
          .eq('id', partId);

      if (kDebugMode) {
        print('✅ Deleted part: $partId');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to delete part: $error');
      }
      rethrow;
    }
  }

  // ===== SEARCH AND FILTER =====

  /// Search parts by name or description
  static Future<List<Part>> searchParts(String query) async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .or('part_name.ilike.%$query%,part_description.ilike.%$query%')
          .order('created_at', ascending: false);

      final parts = response.map((json) => Part.fromJson(json)).toList();

      if (kDebugMode) {
        print('✅ Found ${parts.length} parts matching: $query');
      }

      return parts;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to search parts: $error');
      }
      rethrow;
    }
  }

  /// Get parts by status
  static Future<List<Part>> getPartsByStatus(String status) async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .eq('part_status', status)
          .order('created_at', ascending: false);

      final parts = response.map((json) => Part.fromJson(json)).toList();

      if (kDebugMode) {
        print('✅ Retrieved ${parts.length} parts with status: $status');
      }

      return parts;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get parts by status: $error');
      }
      rethrow;
    }
  }

  /// Get parts by location
  static Future<List<Part>> getPartsByLocation(String location) async {
    try {
      final response = await SupabaseConfig.database
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .ilike('part_location', '%$location%')
          .order('created_at', ascending: false);

      final parts = response.map((json) => Part.fromJson(json)).toList();

      if (kDebugMode) {
        print('✅ Retrieved ${parts.length} parts in location: $location');
      }

      return parts;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get parts by location: $error');
      }
      rethrow;
    }
  }

  // ===== STATISTICS =====

  /// Get parts statistics
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

      final stats = {
        'totalParts': totalParts,
        'activeParts': activeParts,
        'inactiveParts': inactiveParts,
        'locationBreakdown': locationGroups,
      };

      if (kDebugMode) {
        print('✅ Retrieved parts statistics');
      }

      return stats;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get parts statistics: $error');
      }
      rethrow;
    }
  }

  // ===== ERROR HANDLING =====

  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    return SupabaseConfig.handleError(error);
  }
}
