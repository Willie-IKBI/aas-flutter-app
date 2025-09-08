import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class StageManagementService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Define the stage flow
  static const List<String> stageFlow = [
    'order_captured',
    'wash_bay',
    'assessment',
    'quotation',
    'approval',
    'job_commence',
    'paint',
    'dispatch',
  ];

  // Get all stages with their display names
  static List<Map<String, String>> getAllStages() {
    return stageFlow
        .map((stage) => {
              'key': stage,
              'displayName': getStageDisplayName(stage),
            })
        .toList();
  }

  // Get stage display name
  static String getStageDisplayName(String stage) {
    switch (stage.toLowerCase()) {
      case 'order_captured':
        return 'Order Captured';
      case 'wash_bay':
        return 'Wash Bay';
      case 'assessment':
        return 'Assessment';
      case 'quotation':
        return 'Quotation';
      case 'approval':
        return 'Approval';
      case 'job_commence':
        return 'Job Commence';
      case 'paint':
        return 'Paint';
      case 'dispatch':
        return 'Dispatch';
      default:
        return stage;
    }
  }

  // Get stage color
  static Color getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'order_captured':
        return const Color(0xFF3B82F6); // Blue
      case 'wash_bay':
        return const Color(0xFF10B981); // Green
      case 'assessment':
        return const Color(0xFFF59E0B); // Amber
      case 'quotation':
        return const Color(0xFF8B5CF6); // Purple
      case 'approval':
        return const Color(0xFFEF4444); // Red
      case 'job_commence':
        return const Color(0xFF06B6D4); // Cyan
      case 'paint':
        return const Color(0xFFEC4899); // Pink
      case 'dispatch':
        return const Color(0xFF84CC16); // Lime
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Get next stage
  static String? getNextStage(String currentStage) {
    final currentIndex = stageFlow.indexOf(currentStage);
    if (currentIndex >= 0 && currentIndex < stageFlow.length - 1) {
      return stageFlow[currentIndex + 1];
    }
    return null;
  }

  // Get previous stage
  static String? getPreviousStage(String currentStage) {
    final currentIndex = stageFlow.indexOf(currentStage);
    if (currentIndex > 0) {
      return stageFlow[currentIndex - 1];
    }
    return null;
  }

  // Check if stage transition is valid
  static bool canMoveToStage(String currentStage, String targetStage) {
    final currentIndex = stageFlow.indexOf(currentStage);
    final targetIndex = stageFlow.indexOf(targetStage);

    if (currentIndex == -1 || targetIndex == -1) return false;

    // Allow moving forward or backward by one stage
    return (targetIndex - currentIndex).abs() <= 1;
  }

  // Get orders by stage
  static Future<List<Order>> getOrdersByStage(String stage) async {
    try {
// First, let's check what statuses exist in the database
      final allOrders = await _supabase
          .from('orders')
          .select('id, status, current_stage')
          .eq('current_stage', stage);

      for (final order in allOrders) {}

      // Get orders without status filter first to see what we have
      final response = await _supabase
          .from('orders')
          .select()
          .eq('current_stage', stage)
          .order('created_at', ascending: false);

      final orders = response.map((json) => Order.fromJson(json)).toList();
      return orders;
    } catch (e) {
      return [];
    }
  }

  // Move order to stage
  static Future<bool> moveOrderToStage(
    int orderId,
    String newStage, {
    String? notes,
    Map<String, dynamic>? payload,
  }) async {
    try {
// Check authentication
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get current order
      final orderResponse =
          await _supabase.from('orders').select().eq('id', orderId).single();

      final currentStage = orderResponse['current_stage'] as String;

// Create stage event (matching the actual database schema)
      final stageEventData = {
        'order_id': orderId,
        'stage': newStage,
        'opened_at': DateTime.now().toIso8601String(),
        'actor_id': currentUserId,
        'notes': notes ?? '',
        'payload': {
          'previous_stage': currentStage,
          ...?payload,
        },
      };

// Update order stage and create stage event
      try {
        final updateResponse = await _supabase.from('orders').update({
          'current_stage': newStage,
        }).eq('id', orderId);
      } catch (updateError) {
        throw Exception('Failed to update order stage: $updateError');
      }

      try {
        final eventResponse =
            await _supabase.from('order_stage_events').insert(stageEventData);
      } catch (eventError) {
// Don't throw here, as the order update was successful
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get stage counts
  static Future<Map<String, int>> getStageCounts() async {
    try {
// First, let's see what statuses exist in the database
      final allOrders =
          await _supabase.from('orders').select('id, status, current_stage');

      for (final order in allOrders) {}

      // Get all orders without status filter to see what we have
      final response = await _supabase.from('orders').select('current_stage');

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

  // Get stage events for an order
  static Future<List<Map<String, dynamic>>> getStageEvents(int orderId) async {
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

  // Get stage progress percentage
  static double getStageProgress(String stage) {
    final currentIndex = stageFlow.indexOf(stage);
    if (currentIndex == -1) return 0.0;
    return (currentIndex + 1) / stageFlow.length;
  }

  // Get stage icon
  static IconData getStageIcon(String stage) {
    switch (stage.toLowerCase()) {
      case 'order_captured':
        return Icons.receipt_long;
      case 'wash_bay':
        return Icons.water_drop;
      case 'assessment':
        return Icons.assessment;
      case 'quotation':
        return Icons.request_quote;
      case 'approval':
        return Icons.approval;
      case 'job_commence':
        return Icons.play_arrow;
      case 'paint':
        return Icons.brush;
      case 'dispatch':
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }

  // Test function to verify stage transition works
  static Future<bool> testStageTransition(int orderId) async {
    try {
// Get current order
      final orderResponse =
          await _supabase.from('orders').select().eq('id', orderId).single();

      final currentStage = orderResponse['current_stage'] as String;
// Try to move to next stage
      final nextStage = getNextStage(currentStage);
      if (nextStage != null) {
        return await moveOrderToStage(orderId, nextStage,
            notes: 'Test transition');
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
