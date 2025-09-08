import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/stage_management_service.dart';

class OrderSplitView extends StatefulWidget {
  const OrderSplitView({
    super.key,
    required this.orders,
    required this.onOrderTap,
    this.onOrderEdit,
    this.onOrderDelete,
    this.showActions = true,
    this.splitRatio = 0.4,
  });

  final List<Order> orders;
  final Function(Order) onOrderTap;
  final Function(Order)? onOrderEdit;
  final Function(Order)? onOrderDelete;
  final bool showActions;
  final double splitRatio;

  @override
  State<OrderSplitView> createState() => _OrderSplitViewState();
}

class _OrderSplitViewState extends State<OrderSplitView> {
  Order? _selectedOrder;
  double _splitRatio = 0.4;

  @override
  void initState() {
    super.initState();
    _splitRatio = widget.splitRatio;
    if (widget.orders.isNotEmpty) {
      _selectedOrder = widget.orders.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return _buildEmptyState(context);
    }

    return Row(
      children: [
        // Left panel - Order list
        SizedBox(
          width: MediaQuery.of(context).size.width * _splitRatio,
          child: _buildOrderList(context),
        ),
        
        // Resize handle
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final screenWidth = MediaQuery.of(context).size.width;
              final newRatio = (details.globalPosition.dx / screenWidth).clamp(0.2, 0.8);
              _splitRatio = newRatio;
            });
          },
          child: Container(
            width: 4,
            color: AppColors.outline.withValues(alpha: 0.3),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        
        // Right panel - Order details
        Expanded(
          child: _buildOrderDetails(context),
        ),
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

  Widget _buildOrderList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.list,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Orders (${widget.orders.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          
          // Order list
          Expanded(
            child: ListView.builder(
              itemCount: widget.orders.length,
              itemBuilder: (context, index) {
                final order = widget.orders[index];
                final isSelected = _selectedOrder?.id == order.id;
                return _buildOrderListItem(context, order, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(BuildContext context, Order order, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _selectedOrder = order;
          });
        },
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: StageManagementService.getStageColor(order.currentStage.toDatabaseString()).withValues(alpha: 0.2),
          child: Text(
            '#${order.id}',
            style: TextStyle(
              color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          order.customerName ?? 'Customer ID: ${order.customerId}',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  StageManagementService.getStageIcon(order.currentStage.toDatabaseString()),
                  size: 12,
                  color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                ),
                const SizedBox(width: 4),
                Text(
                  StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString()),
                  style: TextStyle(
                    color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(context, order.status),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    if (_selectedOrder == null) {
      return _buildNoSelectionState(context);
    }

    final order = _selectedOrder!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${order.id} Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (widget.showActions) _buildActionButtons(context, order),
              ],
            ),
          ),
          
          // Details content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    context,
                    'Basic Information',
                    Icons.info,
                    [
                      _buildDetailRow('Order ID', '#${order.id}'),
                      _buildDetailRow('Customer', order.customerName ?? 'Customer ID: ${order.customerId}'),
                      _buildDetailRow('Description', order.description),
                      _buildDetailRow('Status', _getStatusText(order.status)),
                      _buildDetailRow('Created Date', _formatDate(order.orderDate)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildDetailSection(
                    context,
                    'Workflow Information',
                    Icons.timeline,
                    [
                      _buildDetailRow('Current Stage', StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString())),
                      _buildDetailRow('Sales Rep', order.salesRepName ?? 'Unassigned'),
                      if (order.equipmentType != null)
                        _buildDetailRow('Equipment Type', order.equipmentType!),
                      if (order.equipmentModel != null)
                        _buildDetailRow('Equipment Model', order.equipmentModel!),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildDetailSection(
                    context,
                    'Timeline',
                    Icons.history,
                    [
                      _buildTimelineItem('Order Created', order.orderDate, Icons.add_circle),
                      if (order.status == OrderStatus.inProgress)
                        _buildTimelineItem('In Progress', order.orderDate.add(const Duration(days: 1)), Icons.play_circle),
                      if (order.status == OrderStatus.complete)
                        _buildTimelineItem('Completed', order.orderDate.add(const Duration(days: 3)), Icons.check_circle),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select an Order',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an order from the list to view details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
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
        if (widget.onOrderEdit != null)
          IconButton(
            onPressed: () => widget.onOrderEdit!(order),
            icon: const Icon(Icons.edit, size: 20),
            tooltip: 'Edit Order',
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        if (widget.onOrderDelete != null)
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, order),
            icon: const Icon(Icons.delete, size: 20),
            tooltip: 'Delete Order',
            style: IconButton.styleFrom(
              foregroundColor: Colors.red,
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
              widget.onOrderDelete!(order);
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.complete:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.waitingApproval:
        return 'Waiting Approval';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.draft:
        return 'Draft';
      default:
        return status.toDisplayString();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
