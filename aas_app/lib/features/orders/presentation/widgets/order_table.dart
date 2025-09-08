import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/stage_management_service.dart';

class OrderTable extends StatefulWidget {
  const OrderTable({
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
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  String _sortColumn = 'id';
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return _buildEmptyState(context);
    }

    final sortedOrders = List<Order>.from(widget.orders);
    sortedOrders.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'id':
          comparison = a.id.compareTo(b.id);
          break;
        case 'customer':
          comparison = (a.customerName ?? '').compareTo(b.customerName ?? '');
          break;
        case 'description':
          comparison = a.description.compareTo(b.description);
          break;
        case 'stage':
          comparison = a.currentStage.toDatabaseString().compareTo(b.currentStage.toDatabaseString());
          break;
        case 'status':
          comparison = a.status.toDisplayString().compareTo(b.status.toDisplayString());
          break;
        case 'date':
          comparison = a.orderDate.compareTo(b.orderDate);
          break;
        case 'salesRep':
          comparison = (a.salesRepName ?? '').compareTo(b.salesRepName ?? '');
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _getSortColumnIndex(),
        sortAscending: _sortAscending,
        columns: [
          _buildDataColumn('Order', 'id', Icons.tag),
          _buildDataColumn('Client', 'customer', Icons.person),
          _buildDataColumn('Description', 'description', Icons.description),
          _buildDataColumn('Stage', 'stage', Icons.timeline),
          _buildDataColumn('Status', 'status', Icons.flag),
          _buildDataColumn('Sales Rep', 'salesRep', Icons.person_outline),
          _buildDataColumn('Created', 'date', Icons.calendar_today),
          if (widget.showActions)
            const DataColumn(
              label: Text('Actions'),
              numeric: false,
            ),
        ],
        rows: sortedOrders.map((order) => _buildDataRow(context, order)).toList(),
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

  DataColumn _buildDataColumn(String label, String columnId, IconData icon) {
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = columnId;
          _sortAscending = ascending;
        });
      },
    );
  }

  DataRow _buildDataRow(BuildContext context, Order order) {
    return DataRow(
      cells: [
        DataCell(
          GestureDetector(
            onTap: () => widget.onOrderTap(order),
            child: Text(
              '#${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            order.customerName ?? 'Customer ID: ${order.customerId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              order.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                StageManagementService.getStageIcon(order.currentStage.toDatabaseString()),
                size: 16,
                color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
              ),
              const SizedBox(width: 8),
              Text(
                StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString()),
                style: TextStyle(
                  color: StageManagementService.getStageColor(order.currentStage.toDatabaseString()),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(_buildStatusChip(context, order.status)),
        DataCell(
          Text(
            order.salesRepName ?? 'Unassigned',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(_formatDate(order.orderDate)),
        ),
        if (widget.showActions)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onOrderEdit != null)
                  IconButton(
                    onPressed: () => widget.onOrderEdit!(order),
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit Order',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                if (widget.onOrderDelete != null)
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context, order),
                    icon: const Icon(Icons.delete, size: 18),
                    tooltip: 'Delete Order',
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
      ],
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

  int? _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'id':
        return 0;
      case 'customer':
        return 1;
      case 'description':
        return 2;
      case 'stage':
        return 3;
      case 'status':
        return 4;
      case 'salesRep':
        return 5;
      case 'date':
        return 6;
      default:
        return null;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
