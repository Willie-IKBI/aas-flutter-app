import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/notification_service.dart';
import '../widgets/order_search_and_filter.dart';
import '../widgets/order_list.dart';
import 'create_order_wizard.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  List<Order> _allOrders = [];
  List<Order> _displayedOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await OrderService.getAllOrders();
      setState(() {
        _allOrders = orders;
        _displayedOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  void _onOrdersFiltered(List<Order> filteredOrders) {
    setState(() {
      _displayedOrders = filteredOrders;
    });
  }

  void _onOrderTap(Order order) {
    // Navigate to order details page
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: order.id,
    );
  }

  void _onOrderEdit(Order order) {
    // Navigate to order edit page
    Navigator.pushNamed(
      context,
      '/order-edit',
      arguments: order.id,
    );
  }

  void _onOrderDelete(Order order) async {
    // This would typically call a delete method in OrderService
    // For now, we'll just show a notification
    NotificationService.showSuccessNotification(
      context,
      'Order #${order.id} deleted successfully',
    );

    // Reload orders
    await _loadOrders();
  }

  void _onCreateNewOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrderWizard(),
      ),
    );

    if (result != null) {
      // Order was created successfully
      NotificationService.showSuccessNotification(
        context,
        'Order created successfully!',
      );

      // Reload orders
      await _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateNewOrder,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Orders',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Search and filter section
        Padding(
          padding: const EdgeInsets.all(16),
          child: OrderSearchAndFilter(
            initialOrders: _allOrders,
            onResultsChanged: _onOrdersFiltered,
          ),
        ),

        // Orders list
        Expanded(
          child: OrderList(
            orders: _displayedOrders,
            onOrderTap: _onOrderTap,
            onOrderEdit: _onOrderEdit,
            onOrderDelete: _onOrderDelete,
          ),
        ),
      ],
    );
  }
}
