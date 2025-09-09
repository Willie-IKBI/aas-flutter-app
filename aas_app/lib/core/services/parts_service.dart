import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'error_service.dart';
import 'tenant_context_service.dart';

/// Core service for parts operations with RLS support
class PartsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Gets all parts for the current business
  static Future<List<Map<String, dynamic>>> getAllParts() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.getAllParts');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets a part by ID (with RLS validation)
  static Future<Map<String, dynamic>?> getPartById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.getPartById');
      if (error is PostgrestException && error.code == 'PGRST116') {
        return null; // No rows returned
      }
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Searches parts by query (with RLS)
  static Future<List<Map<String, dynamic>>> searchParts(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .or('part_number.ilike.%$query%,part_description.ilike.%$query%,part_name.ilike.%$query%')
          .order('part_number');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.searchParts');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Creates a new part (with RLS)
  static Future<Map<String, dynamic>> createPart(
      Map<String, dynamic> partData) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .insert(partData)
          .select()
          .single();

      return response;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.createPart');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Updates an existing part (with RLS)
  static Future<Map<String, dynamic>> updatePart(
      int id, Map<String, dynamic> partData) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .update(partData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.updatePart');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Deletes a part (with RLS)
  static Future<void> deletePart(int id) async {
    try {
      await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .delete()
          .eq('id', id);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.deletePart');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets parts by category (with RLS)
  static Future<List<Map<String, dynamic>>> getPartsByCategory(
      String category) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .eq('part_status', category)
          .order('part_number');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.getPartsByCategory');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets parts with low stock (with RLS)
  static Future<List<Map<String, dynamic>>> getLowStockParts(
      int threshold) async {
    try {
      // Since the database doesn't have quantity_in_stock, we'll return parts with 'Low Stock' status
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select()
          .eq('part_status', 'Low Stock')
          .order('part_name');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.getLowStockParts');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Updates part quantity (with RLS)
  static Future<Map<String, dynamic>> updatePartQuantity(
      int id, int newQuantity) async {
    try {
      // Since the database doesn't have quantity_in_stock, we'll update the status based on quantity
      String status = newQuantity > 10 ? 'Active' : 'Low Stock';
      
      final response = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .update({'part_status': status})
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.updatePartQuantity');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets parts statistics for the current business
  static Future<Map<String, dynamic>> getPartsStatistics() async {
    try {
      // Get total parts count using simple select and length
      final totalResponse = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select('id');

      // Get low stock count using simple select and length
      final lowStockResponse = await _supabase
          .from(SupabaseConfig.partsInventoryTable)
          .select('id')
          .eq('part_status', 'Low Stock');

      return {
        'total_parts': totalResponse.length,
        'low_stock_parts': lowStockResponse.length,
      };
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'PartsService.getPartsStatistics');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }
}
