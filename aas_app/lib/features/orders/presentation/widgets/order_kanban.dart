import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/stage_management_service.dart';

class OrderKanban extends StatelessWidget {
  const OrderKanban({
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

    // Group orders by stage
    final Map<String, List<Order>> ordersByStage = {};
    for (final order in orders) {
      final stage = order.currentStage.toDatabaseString();
      ordersByStage.putIfAbsent(stage, () => []).add(order);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          ...StageManagementService.stageFlow.map((stage) {
            final stageOrders = ordersByStage[stage] ?? [];
            return _buildStageColumn(context, stage, stageOrders);
          }),
          const SizedBox(width: 16),
        ],
      ),
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

  Widget _buildStageColumn(BuildContext context, String stage, List<Order> stageOrders) {
    final stageColor = StageManagementService.getStageColor(stage);
    final stageIcon = StageManagementService.getStageIcon(stage);
    final stageName = StageManagementService.getStageDisplayName(stage);

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stageColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: stageColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(stageIcon, color: stageColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stageName,
                    style: TextStyle(
                      color: stageColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stageOrders.length}',
                    style: TextStyle(
                      color: stageColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Orders in this stage
          Expanded(
            child: ListView.builder(
              itemCount: stageOrders.length,
              itemBuilder: (context, index) {
                final order = stageOrders[index];
                return _buildOrderCard(context, order);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              if (order.description.isNotEmpty) ...[
                Text(
                  order.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Equipment details
              if (order.equipmentType != null || order.equipmentModel != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.build,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${order.equipmentType ?? ''} ${order.equipmentModel ?? ''}'.trim(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Sales rep
              if (order.salesRepId != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.salesRepName ?? 'Sales Rep ID: ${order.salesRepId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Date and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Created: ${_formatDate(order.orderDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  if (showActions) _buildActionButtons(context, order),
                ],
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
