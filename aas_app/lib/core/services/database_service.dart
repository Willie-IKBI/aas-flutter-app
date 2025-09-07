import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Database Service
///
/// Handles database operations with Supabase.
class DatabaseService {
  // Private constructor to prevent instantiation
  DatabaseService._();

  // ===== CRUD OPERATIONS =====

  /// Insert a single record
  static Future<PostgrestList> insert({
    required String table,
    required Map<String, dynamic> data,
    String? returning,
  }) async {
    try {
      final response = await SupabaseConfig.database
          .from(table)
          .insert(data)
          .select(returning ?? '*');

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Insert multiple records
  static Future<PostgrestList> insertMany({
    required String table,
    required List<Map<String, dynamic>> data,
    String? returning,
  }) async {
    try {
      final response = await SupabaseConfig.database
          .from(table)
          .insert(data)
          .select(returning ?? '*');

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Select records with optional filters
  static Future<PostgrestList> select({
    required String table,
    String? columns,
    String? filter,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = SupabaseConfig.database.from(table).select(columns ?? '*');

      if (filter != null) {
        query = query.eq(filter, true);
      }

      if (orderBy != null) {
        query = query.order(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      }

      final response = await query;

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Update records
  static Future<PostgrestResponse> update({
    required String table,
    required Map<String, dynamic> data,
    String? filter,
    String? returning,
  }) async {
    try {
      var query =
          SupabaseConfig.database.from(table).update(data).select(returning);

      if (filter != null) {
        query = query.eq(filter, true);
      }

      final response = await query;

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Delete records
  static Future<PostgrestResponse> delete({
    required String table,
    String? filter,
    String? returning,
  }) async {
    try {
      var query =
          SupabaseConfig.database.from(table).delete().select(returning);

      if (filter != null) {
        query = query.eq(filter, true);
      }

      final response = await query;

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  // ===== SPECIFIC TABLE OPERATIONS =====

  /// Get profile by user ID
  static Future<PostgrestResponse> getProfile(String userId) async {
    return select(
      table: SupabaseConfig.profilesTable,
      filter: 'id.eq.$userId',
    );
  }

  /// Get customer by ID
  static Future<PostgrestResponse> getCustomer(int customerId) async {
    return select(
      table: SupabaseConfig.customersTable,
      filter: 'id.eq.$customerId',
    );
  }

  /// Get order by ID
  static Future<PostgrestResponse> getOrder(int orderId) async {
    return select(
      table: SupabaseConfig.ordersTable,
      filter: 'id.eq.$orderId',
    );
  }

  /// Get orders by customer ID
  static Future<PostgrestResponse> getOrdersByCustomer(int customerId) async {
    return select(
      table: SupabaseConfig.ordersTable,
      filter: 'customer_id.eq.$customerId',
      orderBy: 'created_at.desc',
    );
  }

  /// Get orders by status
  static Future<PostgrestResponse> getOrdersByStatus(String status) async {
    return select(
      table: SupabaseConfig.ordersTable,
      filter: 'status.eq.$status',
      orderBy: 'created_at.desc',
    );
  }

  /// Get orders by stage
  static Future<PostgrestResponse> getOrdersByStage(String stage) async {
    return select(
      table: SupabaseConfig.ordersTable,
      filter: 'current_stage.eq.$stage',
      orderBy: 'created_at.desc',
    );
  }

  /// Get stage events by order ID
  static Future<PostgrestResponse> getStageEvents(int orderId) async {
    return select(
      table: SupabaseConfig.orderStageEventsTable,
      filter: 'order_id.eq.$orderId',
      orderBy: 'created_at.asc',
    );
  }

  /// Get documents by order ID
  static Future<PostgrestResponse> getOrderDocuments(int orderId) async {
    return select(
      table: SupabaseConfig.orderDocumentsTable,
      filter: 'order_id.eq.$orderId',
      orderBy: 'created_at.desc',
    );
  }

  /// Get parts by order ID
  static Future<PostgrestResponse> getOrderParts(int orderId) async {
    return select(
      table: SupabaseConfig.orderPartsTable,
      filter: 'order_id.eq.$orderId',
    );
  }

  /// Get resource allocations by order ID
  static Future<PostgrestResponse> getResourceAllocations(int orderId) async {
    return select(
      table: SupabaseConfig.resourceAllocationsTable,
      filter: 'order_id.eq.$orderId',
      orderBy: 'created_at.desc',
    );
  }

  /// Search parts by name
  static Future<PostgrestResponse> searchParts(String searchTerm) async {
    return select(
      table: SupabaseConfig.partsInventoryTable,
      filter: 'part_name.ilike.%$searchTerm%',
      orderBy: 'part_name.asc',
    );
  }

  // ===== REAL-TIME SUBSCRIPTIONS =====

  /// Subscribe to table changes
  static RealtimeChannel subscribeToTable({
    required String table,
    required String event,
    required Function(Map<String, dynamic>) onData,
  }) {
    final channel = SupabaseConfig.realtime.channel('public:$table').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: event,
        schema: 'public',
        table: table,
      ),
      (payload, [ref]) {
        onData(payload);
      },
    ).subscribe();

    if (kDebugMode) {}

    return channel;
  }

  /// Subscribe to order changes
  static RealtimeChannel subscribeToOrders({
    required Function(Map<String, dynamic>) onData,
  }) {
    return subscribeToTable(
      table: SupabaseConfig.ordersTable,
      event: '*',
      onData: onData,
    );
  }

  /// Subscribe to stage events
  static RealtimeChannel subscribeToStageEvents({
    required Function(Map<String, dynamic>) onData,
  }) {
    return subscribeToTable(
      table: SupabaseConfig.orderStageEventsTable,
      event: '*',
      onData: onData,
    );
  }

  /// Subscribe to documents
  static RealtimeChannel subscribeToDocuments({
    required Function(Map<String, dynamic>) onData,
  }) {
    return subscribeToTable(
      table: SupabaseConfig.orderDocumentsTable,
      event: '*',
      onData: onData,
    );
  }

  // ===== UTILITY METHODS =====

  /// Execute raw SQL query
  static Future<PostgrestResponse> executeQuery(String query) async {
    try {
      final response = await SupabaseConfig.database.rpc('exec_sql', params: {
        'query': query,
      });

      if (kDebugMode) {}

      return response;
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Get table count
  static Future<int> getTableCount(String table) async {
    try {
      final response = await SupabaseConfig.database
          .from(table)
          .select(const FetchOptions(count: CountOption.exact));

      return response.count ?? 0;
    } catch (error) {
      if (kDebugMode) {}
      return 0;
    }
  }

  /// Check if record exists
  static Future<bool> recordExists({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      final response = await SupabaseConfig.database
          .from(table)
          .select(column)
          .eq(column, value)
          .limit(1);

      return response.isNotEmpty;
    } catch (error) {
      if (kDebugMode) {}
      return false;
    }
  }

  /// Get last inserted ID
  static Future<int?> getLastInsertedId(String table) async {
    try {
      final response = await SupabaseConfig.database
          .from(table)
          .select('id')
          .order('id', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first['id'] as int?;
      }
      return null;
    } catch (error) {
      if (kDebugMode) {}
      return null;
    }
  }

  // ===== ERROR HANDLING =====

  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    return SupabaseConfig.handleError(error);
  }

  /// Check if error is a constraint violation
  static bool isConstraintViolation(dynamic error) {
    if (error is PostgrestException) {
      return error.code == '23505'; // Unique constraint violation
    }
    return false;
  }

  /// Check if error is a foreign key violation
  static bool isForeignKeyViolation(dynamic error) {
    if (error is PostgrestException) {
      return error.code == '23503'; // Foreign key constraint violation
    }
    return false;
  }

  /// Check if error is a not null violation
  static bool isNotNullViolation(dynamic error) {
    if (error is PostgrestException) {
      return error.code == '23502'; // Not null constraint violation
    }
    return false;
  }
}
