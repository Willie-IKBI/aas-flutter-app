import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'customer_details_modal.dart';
import '../../../../core/services/customer_service.dart';
import '../providers/customer_selection_provider.dart';

class CustomerSelectionStep extends StatefulWidget {
  const CustomerSelectionStep({
    super.key,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onNewCustomerCreated,
  });
  final Customer? selectedCustomer;
  final Function(Customer) onCustomerSelected;
  final Function(Customer) onNewCustomerCreated;

  @override
  State<CustomerSelectionStep> createState() => _CustomerSelectionStepState();
}

class _CustomerSelectionStepState extends State<CustomerSelectionStep> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final clientResults = await CustomerService.searchCustomers(query);
      final results =
          clientResults.map((client) => Customer.fromClient(client)).toList();
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _showCreateCustomerModal() async {
    final customer = await showDialog<Customer>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomerDetailsModal(),
    );

    if (customer != null) {
      widget.onNewCustomerCreated(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Customer',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Search for an existing customer or create a new one',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search field
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.glassGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search customers by name...',
                  hintStyle: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                  ),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Create new customer button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showCreateCustomerModal,
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Create New Customer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selected customer display
            if (widget.selectedCustomer != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedCustomer!.clientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.selectedCustomer!.contactName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Contact: ${widget.selectedCustomer!.contactName}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                          if (widget.selectedCustomer!.contactEmail !=
                              null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.selectedCustomer!.contactEmail!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          widget.onCustomerSelected(widget.selectedCustomer!);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        tooltip: 'Change customer',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Search results or empty state
            if (_searchResults.isNotEmpty) ...[
              const Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final customer = _searchResults[index];
                    final isSelected =
                        widget.selectedCustomer?.id == customer.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.primaryGradient
                            : AppColors.glassGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.onCustomerSelected(customer);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AppColors.infoGradient
                                        : AppColors.glassGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.outline
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      customer.clientName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.clientName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      if (customer.contactName != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Contact: ${customer.contactName}',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.9)
                                                : AppColors.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      if (customer.contactEmail != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          customer.contactEmail!,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.9)
                                                : AppColors.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      if (customer.contactNumber != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          customer.contactNumber!,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.9)
                                                : AppColors.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (_searchController.text.isNotEmpty && !_isSearching) ...[
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.glassGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No customers found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try a different search term or create a new customer',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_searchController.text.isEmpty) ...[
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.glassGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Search for customers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter a customer name to search or create a new customer',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
