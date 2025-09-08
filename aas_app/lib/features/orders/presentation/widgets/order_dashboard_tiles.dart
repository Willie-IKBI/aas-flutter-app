import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/stage_management_service.dart';

class OrderDashboardTiles extends StatelessWidget {
  const OrderDashboardTiles({
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

    // Calculate metrics
    final urgentOrders = orders.where((order) => _isUrgent(order)).length;
    final overdueOrders = orders.where((order) => _isOverdue(order)).length;
    final recentOrders = orders.where((order) => _isRecent(order)).length;

    return Column(
      children: [
        // Metrics tiles
        _buildMetricsSection(context, urgentOrders, overdueOrders, recentOrders),
        const SizedBox(height: 24),

        // Quick actions
        _buildQuickActionsSection(context),
        const SizedBox(height: 24),

        // Recent activity
        _buildRecentActivitySection(context),
        const SizedBox(height: 24),

        // Orders grid
        _buildOrdersGrid(context),
      ],
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

  Widget _buildMetricsSection(BuildContext context, int urgent, int overdue, int recent) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            context,
            'Active Jobs',
            '${orders.length}',
            Icons.engineering,
            AppColors.primary,
            AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricTile(
            context,
            'Urgent',
            '$urgent',
            Icons.priority_high,
            AppColors.error,
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.error,
                AppColors.error.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricTile(
            context,
            'Overdue',
            '$overdue',
            Icons.warning,
            AppColors.warning,
            AppColors.warningGradient,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricTile(
            context,
            'Recent',
            '$recent',
            Icons.schedule,
            AppColors.info,
            AppColors.infoGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'New Order',
                  Icons.add,
                  AppColors.primary,
                  () {
                    // Navigate to new order page
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Filter Orders',
                  Icons.filter_list,
                  AppColors.info,
                  () {
                    // Show filter options
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Export Data',
                  Icons.download,
                  AppColors.success,
                  () {
                    // Export orders
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final recentOrders = orders.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Show all recent activity
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentOrders.map((order) => _buildActivityItem(context, order)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id} - ${order.customerName ?? 'Unknown Customer'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString())} • ${_formatDate(order.orderDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onOrderTap(order),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
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
                    size: 14,
                    color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(order.orderDate),
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

  bool _isUrgent(Order order) {
    // Define urgent criteria - orders that are in progress and older than 7 days
    return order.status == OrderStatus.inProgress && 
           DateTime.now().difference(order.orderDate).inDays > 7;
  }

  bool _isOverdue(Order order) {
    // Define overdue criteria - orders that are in progress and older than 14 days
    return order.status == OrderStatus.inProgress && 
           DateTime.now().difference(order.orderDate).inDays > 14;
  }

  bool _isRecent(Order order) {
    // Define recent criteria - orders created in the last 3 days
    return DateTime.now().difference(order.orderDate).inDays <= 3;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
