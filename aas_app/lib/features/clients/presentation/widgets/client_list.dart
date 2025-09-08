import 'package:flutter/material.dart';
import 'package:aas_app/core/theme/index.dart';
import 'package:aas_app/core/models/customer.dart';
import 'package:aas_app/core/services/customer_service.dart';
import '../models/client.dart';
import '../pages/edit_client_page.dart';
import '../../../orders/presentation/pages/create_order_wizard.dart';

class ClientList extends StatefulWidget {
  const ClientList({
    super.key,
    required this.filter,
    required this.searchQuery,
  });
  final String filter;
  final String searchQuery;

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  List<Client> _clients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void didUpdateWidget(ClientList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _loadClients();
    }
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Customer> customers;

      if (widget.searchQuery.isNotEmpty) {
        customers = await CustomerService.searchCustomers(widget.searchQuery);
      } else {
        customers = await CustomerService.getAllCustomers();
      }

      // Convert Customer objects to Client objects
      final clients = customers.map((customer) => Client.fromJson(customer.toJson())).toList();

      setState(() {
        _clients = _filterClients(clients);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Client> _filterClients(List<Client> clients) {
    // Sort clients alphabetically by client name
    final sortedClients = List<Client>.from(clients);
    sortedClients.sort((a, b) =>
        a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase()));
    return sortedClients;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
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
            Text(
              'Error loading customers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadClients,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isNotEmpty
                  ? 'No customers found for "${widget.searchQuery}"'
                  : 'No customers yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add your first customer to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClients,
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          final client = _clients[index];
          return _buildClientCard(context, client);
        },
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Client client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showClientDetails(context, client),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildClientAvatar(client),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.clientName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.onBackground,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.primaryContact,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleClientAction(value, client),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (client.address != null || client.industrySector != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (client.industrySector != null)
                      _buildInfoItem(
                        Icons.work,
                        client.industrySector!,
                        AppColors.primary,
                      ),
                    if (client.contactChannel != null)
                      _buildInfoItem(
                        Icons.chat,
                        client.contactChannel!,
                        AppColors.info,
                      ),
                  ],
                ),
              ],
              if (client.address != null) ...[
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.location_on,
                  client.address!,
                  AppColors.secondary,
                ),
              ],
              if (client.createdAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Added ${_formatDate(client.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientAvatar(Client client) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          client.clientName.isNotEmpty
              ? client.clientName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showClientDetails(BuildContext context, Client client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                client.clientName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (client.contactName != null)
                    _buildDetailItem('Contact Person', client.contactName!),
                  if (client.contactEmail != null)
                    _buildDetailItem('Email', client.contactEmail!),
                  if (client.contactNumber != null)
                    _buildDetailItem('Phone', client.contactNumber!),
                  if (client.address != null)
                    _buildDetailItem('Address', client.address!),
                  if (client.industrySector != null)
                    _buildDetailItem('Industry', client.industrySector!),
                  if (client.contactChannel != null)
                    _buildDetailItem('Contact Channel', client.contactChannel!),
                  if (client.notes != null)
                    _buildDetailItem('Notes', client.notes!),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleClientAction('edit', client);
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToCreateOrder(context, client);
                      },
                      child: const Text('Create Order'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onBackground,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleClientAction(String action, Client client) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditClientPage(clientId: client.id.toString()),
          ),
        ).then((updatedClient) {
          if (updatedClient != null) {
            _loadClients(); // Refresh the list
          }
        });
        break;
      case 'delete':
        _showDeleteConfirmation(client);
        break;
    }
  }

  void _navigateToCreateOrder(BuildContext context, Client client) async {
    try {
      // Convert Client to Customer for the wizard
      final customer = Customer.fromClient(client);
      
      // Navigate to CreateOrderWizard with pre-selected customer
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateOrderWizard(
            preSelectedCustomer: customer,
          ),
        ),
      );
      
      // If an order was created successfully, show a success message
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order created successfully for ${client.clientName}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete "${client.clientName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteClient(client);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(Client client) async {
    if (client.id == null) return;

    try {
      await CustomerService.deleteCustomer(client.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${client.clientName} deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadClients(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete customer: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
