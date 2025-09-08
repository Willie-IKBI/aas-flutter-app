import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';
import '../models/user_role.dart';
import 'notification_service.dart';
import 'error_service.dart';
import 'tenant_context_service.dart';

class OrderService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Create a new order
  static Future<Order?> createOrder({
    required DateTime orderDate,
    required String description,
    required int customerId,
    required String? salesRepId,
    String? equipmentType,
    String? equipmentModel,
    String? equipmentSerialNumber,
  }) async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();
      final userFilter = TenantContextService.getUserFilter();

      // Insert the order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'order_date': orderDate.toIso8601String(),
            'description': description,
            'captured_by': userFilter['user_id'],
            'customer_id': customerId,
            'sales_rep_id': salesRepId,
            'business_id': businessFilter['business_id'],
            'status': 'in_progress',
            'current_stage': 'order_captured',
            'equipment_type': equipmentType,
            'equipment_model': equipmentModel,
            'equipment_serial_number': equipmentSerialNumber,
          })
          .select()
          .single();

      final order = Order.fromJson(orderResponse);

      // Create the initial stage event
      await _supabase.from('order_stage_events').insert({
        'order_id': order.id,
        'stage': 'order_captured',
        'opened_at': DateTime.now().toIso8601String(),
        'actor_id': userFilter['user_id'],
        'notes': 'Order created',
      });

      // Get customer details for notification
      if (salesRepId != null) {
        try {
          final customerResponse = await _supabase
              .from('customers')
              .select('client_name')
              .eq('id', customerId)
              .single();

          final customerName =
              customerResponse['client_name'] as String? ?? 'Unknown Customer';

          // The notification will be handled by the real-time listener
        } catch (e) {}
      }

      return order;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'OrderService.createOrder');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  // Get all orders
  static Future<List<Order>> getAllOrders() async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .eq('business_id', businessFilter['business_id'])
          .order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'OrderService.getAllOrders');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  // Get order by ID
  static Future<Order?> getOrderById(int orderId) async {
    try {
      final response = await _supabase.from('orders').select('''
            *,
            customers:customer_id(client_name, contact_name, contact_email, contact_number),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''').eq('id', orderId).single();

      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get orders by customer ID
  static Future<List<Order>> getOrdersByCustomerId(int customerId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get orders by sales rep ID
  static Future<List<Order>> getOrdersBySalesRepId(String salesRepId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .eq('sales_rep_id', salesRepId)
          .order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get orders by status
  static Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase.from('orders').select('''
            *,
            customers:customer_id(client_name, contact_name)
          ''').eq('status', status).order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return [];
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus(
      int orderId, String status, String? notes) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Create stage event for status change
      await _supabase.from('order_stage_events').insert({
        'order_id': orderId,
        'stage': status,
        'opened_at': DateTime.now().toIso8601String(),
        'actor_id': user.id,
        'notes': notes ?? 'Status updated to $status',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update order stage
  static Future<bool> updateOrderStage(
      int orderId, String stage, String? notes) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('orders').update({
        'current_stage': stage,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Create stage event
      await _supabase.from('order_stage_events').insert({
        'order_id': orderId,
        'stage': stage,
        'opened_at': DateTime.now().toIso8601String(),
        'actor_id': user.id,
        'notes': notes ?? 'Stage updated to $stage',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Assign sales rep to order
  static Future<bool> assignSalesRep(int orderId, String salesRepId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('orders').update({
        'sales_rep_id': salesRepId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Create stage event for assignment
      await _supabase.from('order_stage_events').insert({
        'order_id': orderId,
        'stage': 'order_captured',
        'opened_at': DateTime.now().toIso8601String(),
        'actor_id': user.id,
        'notes': 'Sales rep assigned',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update order details (comprehensive update method)
  static Future<bool> updateOrder({
    required int orderId,
    String? description,
    String? equipmentType,
    String? equipmentModel,
    String? equipmentSerialNumber,
    String? notes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (description != null) updates['description'] = description;
      if (equipmentType != null) updates['equipment_type'] = equipmentType;
      if (equipmentModel != null) updates['equipment_model'] = equipmentModel;
      if (equipmentSerialNumber != null)
        updates['equipment_serial_number'] = equipmentSerialNumber;

      await _supabase.from('orders').update(updates).eq('id', orderId);

      // Create stage event for update
      await _supabase.from('order_stage_events').insert({
        'order_id': orderId,
        'stage': 'order_captured',
        'opened_at': DateTime.now().toIso8601String(),
        'actor_id': user.id,
        'notes': notes ?? 'Order details updated',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get order statistics
  static Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final response = await _supabase.rpc('get_order_statistics');

      return response as Map<String, dynamic>;
    } catch (e) {
      return {
        'total_orders': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
        'revenue': 0.0,
      };
    }
  }

  // Search orders
  static Future<List<Order>> searchOrders(String query) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .or('description.ilike.%$query%,equipment_type.ilike.%$query%,equipment_model.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get active orders (not completed or cancelled)
  static Future<List<Order>> getActiveOrders() async {
    try {
      final response = await _supabase.from('orders').select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''').not('status', 'in', [
        'complete',
        'cancelled'
      ]).order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get count of active orders (not completed or cancelled)
  static Future<int> getActiveOrdersCount() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id')
          .not('status', 'in', ['complete', 'cancelled']);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Get count of pending approval orders (waiting_approval status)
  static Future<int> getPendingApprovalCount() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'waiting_approval');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Get count of orders completed today
  static Future<int> getCompletedTodayCount() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'complete')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Stage Management Methods
  Future<List<Order>> getOrdersByStage(String stage) async {
    try {
      final response = await _supabase.from('orders').select('''
            *,
            customers!inner(*),
            profiles!orders_captured_by_fkey(*)
          ''').eq('current_stage', stage).order('created_at', ascending: false);

      return response.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Note: moveOrderToStage method moved to StageManagementService
  // This method was causing errors due to non-existent database function

  Future<Map<String, int>> getStageCounts() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('current_stage')
          .inFilter('status',
              ['in_progress', 'waiting_approval', 'approved', 'in_production']);

      final counts = <String, int>{};
      for (final order in response) {
        final stage = order['current_stage'] as String;
        counts[stage] = (counts[stage] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getStageEvents(int orderId) async {
    try {
      final response = await _supabase.from('order_stage_events').select('''
            *,
            profiles!order_stage_events_actor_id_fkey(*)
          ''').eq('order_id', orderId).order('created_at', ascending: false);

      return response;
    } catch (e) {
      return [];
    }
  }

  Future<bool> canMoveToStage(String currentStage, String targetStage) async {
    const stageFlow = [
      'order_captured',
      'wash_bay',
      'assessment',
      'quotation',
      'approval',
      'job_commence',
      'paint',
      'dispatch',
    ];

    final currentIndex = stageFlow.indexOf(currentStage);
    final targetIndex = stageFlow.indexOf(targetStage);

    if (currentIndex == -1 || targetIndex == -1) return false;

    // Allow moving forward or backward by one stage
    return (targetIndex - currentIndex).abs() <= 1;
  }

  /// Delete an order and all its related data
  /// This includes: stage events, documents, parts, resource allocations, approvals
  Future<bool> deleteOrder(int orderId) async {
    try {
      // Check if user has permission to delete (admin/manager only)
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user profile to check role
      final profileResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      final userRole = profileResponse['role'] as String?;
      if (userRole != 'admin' && userRole != 'manager') {
        throw Exception('Insufficient permissions to delete orders');
      }

      // Get order details for logging
      final orderResponse = await _supabase
          .from('orders')
          .select('id, description, customer_id')
          .eq('id', orderId)
          .single();

      print('Deleting order #$orderId: ${orderResponse['description']}');

      // 1. Delete order documents and their storage files
      await _deleteOrderDocuments(orderId);

      // 2. Delete order stage events
      await _supabase
          .from('order_stage_events')
          .delete()
          .eq('order_id', orderId);

      // 3. Delete order parts
      await _supabase
          .from('order_parts')
          .delete()
          .eq('order_id', orderId);

      // 4. Delete resource allocations
      await _supabase
          .from('resource_allocations')
          .delete()
          .eq('order_id', orderId);

      // 5. Delete approvals (if any)
      await _supabase
          .from('approvals')
          .delete()
          .eq('order_id', orderId);

      // 6. Finally, delete the order itself
      await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId);

      print('Successfully deleted order #$orderId and all related data');
      return true;
    } catch (e) {
      print('Error deleting order #$orderId: $e');
      return false;
    }
  }

  /// Delete order documents and their storage files
  Future<void> _deleteOrderDocuments(int orderId) async {
    try {
      // Get all documents for this order
      final documentsResponse = await _supabase
          .from('order_documents')
          .select('storage_path')
          .eq('order_id', orderId);

      // Delete files from storage
      for (final doc in documentsResponse) {
        final storagePath = doc['storage_path'] as String;
        try {
          await _supabase.storage
              .from('order-files')
              .remove([storagePath]);
          print('Deleted storage file: $storagePath');
        } catch (e) {
          print('Warning: Could not delete storage file $storagePath: $e');
          // Continue with other files even if one fails
        }
      }

      // Delete document records from database
      await _supabase
          .from('order_documents')
          .delete()
          .eq('order_id', orderId);

      print('Deleted ${documentsResponse.length} documents for order #$orderId');
    } catch (e) {
      print('Error deleting documents for order #$orderId: $e');
      // Don't throw here, continue with order deletion
    }
  }

  /// Check if user can delete orders (admin/manager only)
  Future<bool> canDeleteOrder() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      final profileResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      final userRole = profileResponse['role'] as String?;
      return userRole == 'admin' || userRole == 'manager';
    } catch (e) {
      return false;
    }
  }
}
