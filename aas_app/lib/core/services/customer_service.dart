import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import 'error_service.dart';
import 'tenant_context_service.dart';

/// Core service for customer operations with RLS support
class CustomerService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Gets all customers for the current business
  static Future<List<Customer>> getAllCustomers() async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final response = await _supabase
          .from('customers')
          .select()
          .eq('business_id', businessFilter['business_id'])
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.getAllCustomers');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets a customer by ID (with RLS validation)
  static Future<Customer?> getCustomerById(int id) async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
          .eq('business_id', businessFilter['business_id'])
          .single();

      return Customer.fromJson(response);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.getCustomerById');
      if (error is PostgrestException && error.code == 'PGRST116') {
        return null; // No rows returned
      }
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Searches customers by query (with RLS)
  static Future<List<Customer>> searchCustomers(String query) async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final response = await _supabase
          .from('customers')
          .select()
          .eq('business_id', businessFilter['business_id'])
          .or('client_name.ilike.%$query%,contact_name.ilike.%$query%,contact_email.ilike.%$query%')
          .order('client_name');

      return (response as List)
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.searchCustomers');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Creates a new customer (with RLS)
  static Future<Customer> createCustomer(Customer customer) async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final customerData = customer.toJson();
      customerData['business_id'] = businessFilter['business_id'];

      final response = await _supabase
          .from('customers')
          .insert(customerData)
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.createCustomer');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Updates an existing customer (with RLS)
  static Future<Customer> updateCustomer(Customer customer) async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final response = await _supabase
          .from('customers')
          .update(customer.toJson())
          .eq('id', customer.id)
          .eq('business_id', businessFilter['business_id'])
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.updateCustomer');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Deletes a customer (with RLS)
  static Future<void> deleteCustomer(int id) async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      await _supabase
          .from('customers')
          .delete()
          .eq('id', id)
          .eq('business_id', businessFilter['business_id']);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.deleteCustomer');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets customers by business ID (admin function)
  static Future<List<Customer>> getCustomersByBusinessId(
      String businessId) async {
    try {
      // Validate that current user has access to this business
      if (!TenantContextService.hasAccessToBusiness(businessId)) {
        throw Exception('Access denied to business data');
      }

      final response = await _supabase
          .from('customers')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.getCustomersByBusinessId');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets customer count for the current business
  static Future<int> getCustomerCount() async {
    try {
      final businessFilter = TenantContextService.getBusinessFilter();

      final response = await _supabase
          .from('customers')
          .select('id')
          .eq('business_id', businessFilter['business_id']);

      return response.length;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.getCustomerCount');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }
}
