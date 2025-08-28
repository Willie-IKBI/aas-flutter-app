import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';
import '../models/user_role.dart';
import 'notification_service.dart';

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
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Insert the order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'order_date': orderDate.toIso8601String(),
            'description': description,
            'captured_by': user.id,
            'customer_id': customerId,
            'sales_rep_id': salesRepId,
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
      await _supabase
          .from('order_stage_events')
          .insert({
            'order_id': order.id,
            'stage': 'order_captured',
            'opened_at': DateTime.now().toIso8601String(),
            'actor_id': user.id,
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
          
          final customerName = customerResponse['client_name'] as String? ?? 'Unknown Customer';
          
          // The notification will be handled by the real-time listener
          print('Order #${order.id} created and assigned to sales rep $salesRepId for customer $customerName');
        } catch (e) {
          print('Error getting customer details for notification: $e');
        }
      }

      return order;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get all orders
  static Future<List<Order>> getAllOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting all orders: $e');
      return [];
    }
  }

  // Get order by ID
  static Future<Order?> getOrderById(int orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name, contact_email, contact_number),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      print('Error getting order by ID: $e');
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

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by customer ID: $e');
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

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by sales rep ID: $e');
      return [];
    }
  }

  // Get orders by status
  static Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name)
          ''')
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by status: $e');
      return [];
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus(int orderId, String status, String? notes) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // Create stage event for status change
      await _supabase
          .from('order_stage_events')
          .insert({
            'order_id': orderId,
            'stage': status,
            'opened_at': DateTime.now().toIso8601String(),
            'actor_id': user.id,
            'notes': notes ?? 'Status updated to $status',
          });

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Update order stage
  static Future<bool> updateOrderStage(int orderId, String stage, String? notes) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('orders')
          .update({
            'current_stage': stage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // Create stage event
      await _supabase
          .from('order_stage_events')
          .insert({
            'order_id': orderId,
            'stage': stage,
            'opened_at': DateTime.now().toIso8601String(),
            'actor_id': user.id,
            'notes': notes ?? 'Stage updated to $stage',
          });

      return true;
    } catch (e) {
      print('Error updating order stage: $e');
      return false;
    }
  }

  // Assign sales rep to order
  static Future<bool> assignSalesRep(int orderId, String salesRepId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('orders')
          .update({
            'sales_rep_id': salesRepId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // Create stage event for assignment
      await _supabase
          .from('order_stage_events')
          .insert({
            'order_id': orderId,
            'stage': 'order_captured',
            'opened_at': DateTime.now().toIso8601String(),
            'actor_id': user.id,
            'notes': 'Sales rep assigned',
          });

      return true;
    } catch (e) {
      print('Error assigning sales rep: $e');
      return false;
    }
  }

  // Get order statistics
  static Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final response = await _supabase
          .rpc('get_order_statistics');

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error getting order statistics: $e');
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

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error searching orders: $e');
      return [];
    }
  }

  // Get active orders (not completed or cancelled)
  static Future<List<Order>> getActiveOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            customers:customer_id(client_name, contact_name),
            sales_rep:profile!orders_sales_rep_id_fkey(display_name, user_email)
          ''')
          .not('status', 'in', ['complete', 'cancelled'])
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting active orders: $e');
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
      print('Error getting active orders count: $e');
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
      print('Error getting pending approval count: $e');
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
      print('Error getting completed today count: $e');
      return 0;
    }
  }
}
