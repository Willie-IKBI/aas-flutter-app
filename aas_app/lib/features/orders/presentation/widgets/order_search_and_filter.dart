import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/order_service.dart';
import '../../../../features/clients/data/services/customer_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';

class OrderSearchAndFilter extends StatefulWidget {
  final Function(List<Order>) onResultsChanged;
  final List<Order> initialOrders;

  const OrderSearchAndFilter({
    super.key,
    required this.onResultsChanged,
    required this.initialOrders,
  });

  @override
  State<OrderSearchAndFilter> createState() => _OrderSearchAndFilterState();
}

class _OrderSearchAndFilterState extends State<OrderSearchAndFilter> {
  final TextEditingController _searchController = TextEditingController();
  final List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Customer> _customers = [];
  List<UserProfile> _salesReps = [];
  
  // Filter states
  String? _selectedStatus;
  String? _selectedCustomer;
  String? _selectedSalesRep;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'All',
    'in_progress',
    'completed',
    'cancelled',
    'on_hold',
  ];

  @override
  void initState() {
    super.initState();
    _allOrders.addAll(widget.initialOrders);
    _filteredOrders.addAll(widget.initialOrders);
    _loadFilterData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load customers
      final customers = await CustomerService.getAllCustomers();
      
      // Load sales reps
      final allUsers = await AuthService.getAllUsers();
      final salesReps = allUsers.where((user) => user.isSalesRep).toList();

      setState(() {
        _customers = customers.map((client) => Customer.fromClient(client)).toList();
        _salesReps = salesReps;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading filter data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        // Search text filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          final matchesSearch = 
              order.description.toLowerCase().contains(searchLower) ||
              (order.equipmentType?.toLowerCase().contains(searchLower) ?? false) ||
              (order.equipmentModel?.toLowerCase().contains(searchLower) ?? false);
          
          if (!matchesSearch) return false;
        }

        // Status filter
        if (_selectedStatus != null && _selectedStatus != 'All') {
          if (order.status.toDatabaseString() != _selectedStatus) return false;
        }

        // Customer filter
        if (_selectedCustomer != null) {
          if (order.customerId.toString() != _selectedCustomer) return false;
        }

        // Sales rep filter
        if (_selectedSalesRep != null) {
          if (order.salesRepId != _selectedSalesRep) return false;
        }

        // Date range filter
        if (_startDate != null) {
          if (order.orderDate.isBefore(_startDate!)) return false;
        }
        if (_endDate != null) {
          if (order.orderDate.isAfter(_endDate!)) return false;
        }

        return true;
      }).toList();
    });

    widget.onResultsChanged(_filteredOrders);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedCustomer = null;
      _selectedSalesRep = null;
      _startDate = null;
      _endDate = null;
      _filteredOrders = List.from(_allOrders);
    });

    widget.onResultsChanged(_filteredOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Search & Filter Orders',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search orders by description, equipment, or customer...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 16),

          // Filters
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                // Status and Customer filters
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFilter(
                        label: 'Status',
                        value: _selectedStatus,
                        items: _statusOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownFilter(
                        label: 'Customer',
                        value: _selectedCustomer,
                        items: ['All', ..._customers.map((c) => c.id.toString())],
                        displayItems: ['All', ..._customers.map((c) => c.clientName)],
                        onChanged: (value) {
                          setState(() {
                            _selectedCustomer = value == 'All' ? null : value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sales Rep and Date filters
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFilter(
                        label: 'Sales Rep',
                        value: _selectedSalesRep,
                        items: ['All', ..._salesReps.map((r) => r.id)],
                        displayItems: ['All', ..._salesReps.map((r) => r.displayName ?? r.email ?? 'Unknown')],
                        onChanged: (value) {
                          setState(() {
                            _selectedSalesRep = value == 'All' ? null : value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateRangeFilter(),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Results count
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '${_filteredOrders.length} of ${_allOrders.length} orders',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    List<String>? displayItems,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((item) {
            final displayText = displayItems != null 
                ? displayItems[items.indexOf(item)]
                : item;
            return DropdownMenuItem(
              value: item,
              child: Text(
                displayText,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                    _applyFilters();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Start Date',
                          style: TextStyle(
                            color: _startDate != null 
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                    _applyFilters();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'End Date',
                          style: TextStyle(
                            color: _endDate != null 
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
