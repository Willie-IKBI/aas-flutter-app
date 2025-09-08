import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import 'error_service.dart';
import 'tenant_context_service.dart';

/// Core service for customer operations with RLS support
class CustomerService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Gets all customers
  static Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
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

  /// Gets a customer by ID
  static Future<Customer?> getCustomerById(int id) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
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

  /// Searches customers by query
  static Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
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

  /// Creates a new customer
  static Future<Customer> createCustomer(Customer customer) async {
    try {
      final customerData = customer.toJson();

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

  /// Updates an existing customer
  static Future<Customer> updateCustomer(Customer customer) async {
    try {
      final response = await _supabase
          .from('customers')
          .update(customer.toJson())
          .eq('id', customer.id)
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.updateCustomer');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Deletes a customer
  static Future<void> deleteCustomer(int id) async {
    try {
      await _supabase
          .from('customers')
          .delete()
          .eq('id', id);
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.deleteCustomer');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets customers by business ID (admin function) - deprecated for single tenant
  static Future<List<Customer>> getCustomersByBusinessId(
      String businessId) async {
    try {
      // For single tenant setup, just return all customers
      return await getAllCustomers();
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.getCustomersByBusinessId');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }

  /// Gets customer count
  static Future<int> getCustomerCount() async {
    try {
      final response = await _supabase
          .from('customers')
          .select('id');

      return response.length;
    } catch (error) {
      ErrorService.logError(error, StackTrace.current,
          context: 'CustomerService.getCustomerCount');
      throw Exception(ErrorService.mapSupabaseError(error));
    }
  }
}
