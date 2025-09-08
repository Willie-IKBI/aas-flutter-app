import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/stage_management_service.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    super.key,
    required this.orders,
    required this.onOrderTap,
    this.onOrderEdit,
    this.onOrderDelete,
    this.showActions = true,
  });

  final List<Order> orders;
  final Function(Order) onOrderTap;
  final Function(Order)? onOrderEdit;
  final Function(Order)? onOrderDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group orders by date
    final Map<String, List<Order>> ordersByDate = {};
    for (final order in orders) {
      final dateKey = _getDateKey(order.orderDate);
      ordersByDate.putIfAbsent(dateKey, () => []).add(order);
    }

    // Sort dates in descending order (most recent first)
    final sortedDates = ordersByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateOrders = ordersByDate[date]!;
        return _buildDateSection(context, date, dateOrders);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, String date, List<Order> dateOrders) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateHeader(date),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${dateOrders.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Orders for this date
          ...dateOrders.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            return _buildTimelineItem(context, order, index == dateOrders.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Order order, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: AppColors.outline.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Order card
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => onOrderTap(order),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with order ID and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Order #${order.id}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          _buildStatusChip(context, order.status),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Customer name
                      Text(
                        order.customerName ?? 'Customer ID: ${order.customerId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      if (order.description.isNotEmpty) ...[
                        Text(
                          order.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Current stage
                      Row(
                        children: [
                          Icon(
                            StageManagementService.getStageIcon(order.currentStage.toDatabaseString()),
                            size: 16,
                            color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Stage: ${StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString())}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Sales rep and time
                      Row(
                        children: [
                          if (order.salesRepId != null) ...[
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.salesRepName ?? 'Sales Rep ID: ${order.salesRepId}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            _formatTime(order.orderDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (showActions) ...[
                            const SizedBox(width: 8),
                            _buildActionButtons(context, order),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.inProgress:
        color = AppColors.info;
        label = 'In Progress';
        break;
      case OrderStatus.complete:
        color = AppColors.success;
        label = 'Completed';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        break;
      case OrderStatus.waitingApproval:
        color = AppColors.warning;
        label = 'Waiting Approval';
        break;
      case OrderStatus.approved:
        color = AppColors.success;
        label = 'Approved';
        break;
      case OrderStatus.inProduction:
        color = AppColors.primary;
        label = 'In Production';
        break;
      case OrderStatus.draft:
        color = AppColors.onSurfaceVariant;
        label = 'Draft';
        break;
      default:
        color = AppColors.onSurfaceVariant;
        label = status.toDisplayString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onOrderEdit != null)
          IconButton(
            onPressed: () => onOrderEdit!(order),
            icon: const Icon(Icons.edit, size: 16),
            tooltip: 'Edit Order',
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        if (onOrderDelete != null)
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, order),
            icon: const Icon(Icons.delete, size: 16),
            tooltip: 'Delete Order',
            style: IconButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Are you sure you want to delete Order #${order.id}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOrderDelete!(order);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final date = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${day}/${month}/${year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
