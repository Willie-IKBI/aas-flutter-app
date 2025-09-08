import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/services/customer_service.dart';

/// Provider for customer search with AsyncValue
class CustomerSearchNotifier extends AsyncNotifier<List<Customer>> {
  String _currentQuery = '';

  @override
  Future<List<Customer>> build() async {
    // Load all customers initially
    return await CustomerService.getAllCustomers();
  }

  Future<void> searchCustomers(String query) async {
    _currentQuery = query.trim();

    if (_currentQuery.isEmpty) {
      // If no query, show all customers
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => CustomerService.getAllCustomers());
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _performSearch(_currentQuery));
  }

  Future<List<Customer>> _performSearch(String query) async {
    try {
      return await CustomerService.searchCustomers(query);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearSearch() async {
    _currentQuery = '';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => CustomerService.getAllCustomers());
  }

  String get currentQuery => _currentQuery;
}

final customerSearchProvider =
    AsyncNotifierProvider<CustomerSearchNotifier, List<Customer>>(() {
  return CustomerSearchNotifier();
});
