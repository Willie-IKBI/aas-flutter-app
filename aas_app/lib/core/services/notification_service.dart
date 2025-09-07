import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../navigation/app_router.dart';

class NotificationService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Listen for profile changes
  static RealtimeChannel? _profileChannel;
  static RealtimeChannel? _orderChannel;

  static void initializeProfileListener(
      String userId, VoidCallback onProfileUpdate) {
    try {
      _profileChannel = _supabase
          .channel('profile_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profile',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: userId,
            ),
            callback: (payload) {
              onProfileUpdate();
            },
          )
          .subscribe();
    } catch (e) {
// Fallback: use polling instead
      _startPolling(onProfileUpdate);
    }
  }

  // Initialize order notifications for sales reps
  static void initializeOrderListener(
      String salesRepId, VoidCallback onNewOrder) {
    try {
      _orderChannel = _supabase
          .channel('order_notifications')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'orders',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'sales_rep_id',
              value: salesRepId,
            ),
            callback: (payload) {
              onNewOrder();
            },
          )
          .subscribe();
    } catch (e) {}
  }

  static void _startPolling(VoidCallback onProfileUpdate) {
    // Simple polling fallback if real-time fails
    Future.delayed(const Duration(seconds: 5), () {
      onProfileUpdate();
    });
  }

  static void disposeProfileListener() {
    try {
      _profileChannel?.unsubscribe();
      _profileChannel = null;
    } catch (e) {}
  }

  static void disposeOrderListener() {
    try {
      _orderChannel?.unsubscribe();
      _orderChannel = null;
    } catch (e) {}
  }

  // Show notification for role assignment
  static void showRoleAssignedNotification(BuildContext context, String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your role has been assigned: $role'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show notification for pending users
  static void showPendingUsersNotification(BuildContext context, int count) {
    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count user(s) awaiting role assignment'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to user management
              context.goToUserManagement();
            },
          ),
        ),
      );
    }
  }

  // Show notification for new order assignment to sales rep
  static void showNewOrderNotification(
      BuildContext context, String orderId, String customerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.assignment, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'New Order Assigned',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Order #$orderId for $customerName',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to order details
            context.goToOrderDetails(orderId);
          },
        ),
      ),
    );
  }

  // Show notification for order status changes
  static void showOrderStatusNotification(
      BuildContext context, String orderId, String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.update, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Order #$orderId status updated to: $status',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            context.goToOrderDetails(orderId);
          },
        ),
      ),
    );
  }

  // Show success notification
  static void showSuccessNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Show error notification
  static void showErrorNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
