import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Status Colors for AAS App
///
/// This file defines colors and utilities for different order statuses and stages.
class StatusColors {
  // Private constructor to prevent instantiation
  StatusColors._();

  // ===== ORDER STATUS COLORS =====

  /// Get color for order status
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraft;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'waiting_approval':
        return AppColors.statusWaitingApproval;
      case 'approved':
        return AppColors.statusApproved;
      case 'in_production':
        return AppColors.statusInProduction;
      case 'complete':
        return AppColors.statusComplete;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.statusDraft;
    }
  }

  /// Get background color for order status
  static Color getOrderStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.timberwolf800;
      case 'in_progress':
        return AppColors.infoContainer;
      case 'waiting_approval':
        return AppColors.warningContainer;
      case 'approved':
        return AppColors.successContainer;
      case 'in_production':
        return AppColors.secondaryContainer;
      case 'complete':
        return AppColors.successContainer;
      case 'cancelled':
        return AppColors.errorContainer;
      default:
        return AppColors.timberwolf800;
    }
  }

  // ===== ORDER STAGE COLORS =====

  /// Get color for order stage
  static Color getOrderStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'order_captured':
        return AppColors.stageOrderCaptured;
      case 'wash_bay':
        return AppColors.stageWashBay;
      case 'assessment':
        return AppColors.stageAssessment;
      case 'quotation':
        return AppColors.stageQuotation;
      case 'approval':
        return AppColors.stageApproval;
      case 'job_commence':
        return AppColors.stageJobCommence;
      case 'paint':
        return AppColors.stagePaint;
      case 'dispatch':
        return AppColors.stageDispatch;
      default:
        return AppColors.stageOrderCaptured;
    }
  }

  /// Get background color for order stage
  static Color getOrderStageBackgroundColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'order_captured':
        return AppColors.infoContainer;
      case 'wash_bay':
        return const Color(0xFFE0F7FA);
      case 'assessment':
        return AppColors.warningContainer;
      case 'quotation':
        return AppColors.secondaryContainer;
      case 'approval':
        return AppColors.warningContainer;
      case 'job_commence':
        return AppColors.primaryContainer;
      case 'paint':
        return AppColors.secondaryContainer;
      case 'dispatch':
        return AppColors.successContainer;
      default:
        return AppColors.infoContainer;
    }
  }

  // ===== STATUS BADGES =====

  /// Create a status badge widget
  static Widget createStatusBadge({
    required String status,
    required String label,
    bool isStage = false,
    double fontSize = 12,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) {
    final color =
        isStage ? getOrderStageColor(status) : getOrderStatusColor(status);
    final backgroundColor = isStage
        ? getOrderStageBackgroundColor(status)
        : getOrderStatusBackgroundColor(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Create a status chip widget
  static Widget createStatusChip({
    required String status,
    required String label,
    bool isStage = false,
    VoidCallback? onTap,
  }) {
    final color =
        isStage ? getOrderStageColor(status) : getOrderStatusColor(status);
    final backgroundColor = isStage
        ? getOrderStageBackgroundColor(status)
        : getOrderStatusBackgroundColor(status);

    return Semantics(
      label: '${isStage ? 'Stage' : 'Status'}: $label',
      hint: onTap != null ? 'Tap to interact' : null,
      button: onTap != null,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onSelected: onTap != null ? (_) => onTap() : null,
        backgroundColor: backgroundColor,
        selectedColor: backgroundColor,
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  // ===== PROGRESS INDICATORS =====

  /// Create a stage progress indicator
  static Widget createStageProgress({
    required String currentStage,
    required List<String> allStages,
    double height = 4,
    double borderRadius = 2,
  }) {
    final currentIndex = allStages.indexWhere(
      (stage) => stage.toLowerCase() == currentStage.toLowerCase(),
    );
    final progress =
        currentIndex >= 0 ? (currentIndex + 1) / allStages.length : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '${((progress * 100).round())}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== STATUS ICONS =====

  /// Get icon for order status
  static IconData getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.edit_outlined;
      case 'in_progress':
        return Icons.pending_outlined;
      case 'waiting_approval':
        return Icons.schedule_outlined;
      case 'approved':
        return Icons.check_circle_outline;
      case 'in_production':
        return Icons.build_outlined;
      case 'complete':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// Get icon for order stage
  static IconData getOrderStageIcon(String stage) {
    switch (stage.toLowerCase()) {
      case 'order_captured':
        return Icons.add_shopping_cart_outlined;
      case 'wash_bay':
        return Icons.local_car_wash_outlined;
      case 'assessment':
        return Icons.assessment_outlined;
      case 'quotation':
        return Icons.receipt_long_outlined;
      case 'approval':
        return Icons.approval_outlined;
      case 'job_commence':
        return Icons.play_arrow_outlined;
      case 'paint':
        return Icons.format_paint_outlined;
      case 'dispatch':
        return Icons.local_shipping_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ===== STATUS UTILITIES =====

  /// Check if status is active
  static bool isActiveStatus(String status) {
    return ['in_progress', 'waiting_approval', 'approved', 'in_production']
        .contains(status.toLowerCase());
  }

  /// Check if status is completed
  static bool isCompletedStatus(String status) {
    return ['complete'].contains(status.toLowerCase());
  }

  /// Check if status is cancelled
  static bool isCancelledStatus(String status) {
    return ['cancelled'].contains(status.toLowerCase());
  }

  /// Get next stage in the pipeline
  static String? getNextStage(String currentStage) {
    const stages = [
      'order_captured',
      'wash_bay',
      'assessment',
      'quotation',
      'approval',
      'job_commence',
      'paint',
      'dispatch',
    ];

    final currentIndex = stages.indexWhere(
      (stage) => stage.toLowerCase() == currentStage.toLowerCase(),
    );

    if (currentIndex >= 0 && currentIndex < stages.length - 1) {
      return stages[currentIndex + 1];
    }

    return null;
  }

  /// Get previous stage in the pipeline
  static String? getPreviousStage(String currentStage) {
    const stages = [
      'order_captured',
      'wash_bay',
      'assessment',
      'quotation',
      'approval',
      'job_commence',
      'paint',
      'dispatch',
    ];

    final currentIndex = stages.indexWhere(
      (stage) => stage.toLowerCase() == currentStage.toLowerCase(),
    );

    if (currentIndex > 0) {
      return stages[currentIndex - 1];
    }

    return null;
  }

  /// Get stage display name
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

  /// Get status display name
  static String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'in_progress':
        return 'In Progress';
      case 'waiting_approval':
        return 'Waiting Approval';
      case 'approved':
        return 'Approved';
      case 'in_production':
        return 'In Production';
      case 'complete':
        return 'Complete';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
