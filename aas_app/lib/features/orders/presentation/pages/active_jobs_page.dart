import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/order_list.dart';
import '../widgets/job_summary_dialog.dart';

class ActiveJobsPage extends StatefulWidget {
  const ActiveJobsPage({super.key});

  @override
  State<ActiveJobsPage> createState() => _ActiveJobsPageState();
}

class _ActiveJobsPageState extends State<ActiveJobsPage> {
  List<Order> _activeOrders = [];
  List<Order> _displayedOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _loadActiveOrders();
  }

  Future<void> _loadActiveOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the new getActiveOrders method that gets all non-completed/non-cancelled orders
      final orders = await OrderService.getActiveOrders();
      // Debug: Print each order with its status
      for (final order in orders) {
        print(
            'Order ${order.id}: ${order.description} - Status: ${order.status}');
      }

      setState(() {
        _activeOrders = orders;
        _displayedOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load active jobs: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = List<Order>.from(_activeOrders);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((order) {
        return order.description.toLowerCase().contains(query) ||
            (order.equipmentType?.toLowerCase().contains(query) ?? false) ||
            (order.equipmentModel?.toLowerCase().contains(query) ?? false) ||
            order.id.toString().contains(query);
      }).toList();
    }

    // Apply date filter
    if (_selectedFilter == 'This Week') {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      filtered =
          filtered.where((order) => order.createdAt.isAfter(weekAgo)).toList();
    } else if (_selectedFilter == 'This Month') {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      filtered =
          filtered.where((order) => order.createdAt.isAfter(monthAgo)).toList();
    }

    setState(() {
      _displayedOrders = filtered;
    });
  }

  void _onOrderTap(Order order) {
    // Show job summary dialog
    showDialog(
      context: context,
      builder: (context) => JobSummaryDialog(order: order),
    ).then((_) => _loadActiveOrders()); // Refresh after dialog closes
  }

  void _onCreateNewOrder() async {
    context.goToOrderCreate();
    // Note: Order creation success will be handled by the CreateOrderWizard
    // and the user will be navigated back automatically
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateNewOrder,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Active Jobs'),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _loadActiveOrders,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Active Jobs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadActiveOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: 16),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 24),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: 24),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 32),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.infoGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.engineering,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Jobs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Currently in progress - ${_activeOrders.length} jobs',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Search active jobs...',
          prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _onFilterChanged(filter);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          onChanged: (value) {
            if (value != null) _onFilterChanged(value);
          },
          items: _filterOptions.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.onSurfaceVariant),
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_displayedOrders.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadActiveOrders,
        color: AppColors.primary,
        child: OrderList(
          orders: _displayedOrders,
          onOrderTap: _onOrderTap,
          showActions: false,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadActiveOrders,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All'
                        ? 'No active jobs found'
                        : 'No active jobs',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All'
                        ? 'Try adjusting your search or filter criteria'
                        : 'Create a new order to get started',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_searchQuery.isEmpty && _selectedFilter == 'All') ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _onCreateNewOrder,
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Order'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
