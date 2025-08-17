import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/models/client.dart';

class CustomerService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get all customers
  static Future<List<Client>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // Get customer by ID
  static Future<Client?> getCustomerById(int id) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
          .single();

      return Client.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch customer: $e');
    }
  }

  // Create new customer
  static Future<Client> createCustomer(Client customer) async {
    try {
      final response = await _supabase
          .from('customers')
          .insert(customer.toJson())
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  // Update customer
  static Future<Client> updateCustomer(Client customer) async {
    try {
      print('CustomerService.updateCustomer called with customer: ${customer.toJson()}'); // Debug print
      
      if (customer.id == null) {
        throw Exception('Customer ID is required for update');
      }

      print('Customer ID is valid: ${customer.id}'); // Debug print

      final response = await _supabase
          .from('customers')
          .update(customer.toJson())
          .eq('id', customer.id!)
          .select()
          .single();

      print('Supabase response: $response'); // Debug print
      return Client.fromJson(response);
    } catch (e) {
      print('Error in updateCustomer: $e'); // Debug print
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete customer
  static Future<void> deleteCustomer(int id) async {
    try {
      await _supabase
          .from('customers')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Search customers by name
  static Future<List<Client>> searchCustomers(String query) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .ilike('client_name', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  // Get customers by industry sector
  static Future<List<Client>> getCustomersByIndustry(String sector) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('industry_sector', sector)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers by industry: $e');
    }
  }

  // Get customers by contact channel
  static Future<List<Client>> getCustomersByContactChannel(String channel) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('contact_channel', channel)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers by contact channel: $e');
    }
  }

  // Get customer statistics
  static Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      // Get all customers to count them
      final allCustomers = await getAllCustomers();
      final total = allCustomers.length;

      // Get count by industry sector
      final industryResponse = await _supabase
          .from('customers')
          .select('industry_sector')
          .not('industry_sector', 'is', null);

      // Get count by contact channel
      final channelResponse = await _supabase
          .from('customers')
          .select('contact_channel')
          .not('contact_channel', 'is', null);

      // Process industry data
      final industryMap = <String, int>{};
      for (final item in industryResponse as List) {
        final sector = item['industry_sector'] as String;
        industryMap[sector] = (industryMap[sector] ?? 0) + 1;
      }

      // Process channel data
      final channelMap = <String, int>{};
      for (final item in channelResponse as List) {
        final channel = item['contact_channel'] as String;
        channelMap[channel] = (channelMap[channel] ?? 0) + 1;
      }

      return {
        'total': total,
        'byIndustry': industryMap,
        'byChannel': channelMap,
      };
    } catch (e) {
      throw Exception('Failed to fetch customer statistics: $e');
    }
  }
}
