import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_colors.dart';
import 'customer_details_modal.dart';
import '../providers/customer_selection_provider.dart';

class CustomerSelectionStep extends ConsumerStatefulWidget {
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
  ConsumerState<CustomerSelectionStep> createState() =>
      _CustomerSelectionStepState();
}

class _CustomerSelectionStepState extends ConsumerState<CustomerSelectionStep> {
  final TextEditingController _searchController = TextEditingController();

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

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    ref.read(customerSearchProvider.notifier).searchCustomers(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(customerSearchProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Customer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for an existing customer or create a new one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search customers by name, email, or company...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () async {
                        _searchController.clear();
                        await ref.read(customerSearchProvider.notifier).clearSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Selected Customer Display
          if (widget.selectedCustomer != null) ...[
            _buildSelectedCustomerCard(context, widget.selectedCustomer!),
            const SizedBox(height: 24),
          ],

          // Search Results
          Expanded(
            child: searchResultsAsync.when(
              data: (results) => _buildSearchResults(context, results),
              loading: () => _buildLoadingState(context),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
          ),

          // Action Buttons
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateCustomerModal(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Customer'),
                ),
              ),
              const SizedBox(width: 16),
              if (widget.selectedCustomer != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Continue to next step
                    },
                    child: const Text('Continue'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomerCard(BuildContext context, Customer customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              customer.clientName.isNotEmpty
                  ? customer.clientName[0].toUpperCase()
                  : (customer.contactName ?? 'C')[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.clientName.isNotEmpty
                      ? customer.clientName
                      : (customer.contactName ?? 'Unknown'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimaryContainer,
                      ),
                ),
                if (customer.contactEmail?.isNotEmpty ?? false)
                  Text(
                    customer.contactEmail!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Clear selection
            },
            icon: const Icon(Icons.close),
            color: AppColors.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, List<Customer> results) {
    if (results.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final customer = results[index];
        return _buildCustomerTile(context, customer);
      },
    );
  }

  Widget _buildCustomerTile(BuildContext context, Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            customer.clientName.isNotEmpty
                ? customer.clientName[0].toUpperCase()
                : (customer.contactName ?? 'C')[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.clientName.isNotEmpty
              ? customer.clientName
              : (customer.contactName ?? 'Unknown'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.contactEmail?.isNotEmpty ?? false)
              Text(
                customer.contactEmail!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            if (customer.contactNumber?.isNotEmpty ?? false)
              Text(
                customer.contactNumber!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showCustomerDetails(context, customer),
              icon: const Icon(Icons.info_outline),
              tooltip: 'View Details',
            ),
            IconButton(
              onPressed: () => widget.onCustomerSelected(customer),
              icon: const Icon(Icons.check),
              tooltip: 'Select Customer',
            ),
          ],
        ),
        onTap: () => widget.onCustomerSelected(customer),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching customers...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading customers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                ref
                    .read(customerSearchProvider.notifier)
                    .searchCustomers(query);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or create a new customer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => const CustomerDetailsModal(),
    );
  }

  void _showCreateCustomerModal(BuildContext context) {
    // This would show a modal to create a new customer
    // For now, we'll just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Customer'),
        content: const Text('Customer creation form would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle customer creation
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
