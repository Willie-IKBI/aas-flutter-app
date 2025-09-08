import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/services/customer_service.dart';
import '../models/client.dart';
import '../widgets/client_form_field.dart';

class EditClientPage extends StatefulWidget {
  const EditClientPage({
    super.key,
    required this.clientId,
  });
  final String clientId;

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  TextEditingController? _clientNameController;
  TextEditingController? _contactNameController;
  TextEditingController? _contactNumberController;
  TextEditingController? _contactEmailController;
  TextEditingController? _addressController;
  TextEditingController? _industrySectorController;
  TextEditingController? _contactChannelController;
  TextEditingController? _notesController;
  
  // Form state
  bool _isLoading = false;
  bool _isFormValid = false;
  Client? _client;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    try {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });

      // Parse the client ID to integer
      final clientId = int.tryParse(widget.clientId);
      if (clientId == null) {
        throw Exception('Invalid client ID: ${widget.clientId}');
      }

      // Load customer from service
      final customer = await CustomerService.getCustomerById(clientId);
      if (customer == null) {
        throw Exception('Client not found');
      }

      // Convert Customer to Client
      final client = Client.fromJson(customer.toJson());
      
      setState(() {
        _client = client;
        _isInitialLoading = false;
        _errorMessage = null;
      });

      // Initialize form controllers after client is loaded
      _initializeControllers();
      _setupFormValidation();
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'Failed to load client: $e';
      });
    }
  }

  void _initializeControllers() {
    if (_client == null) return;
    
    // Initialize controllers if they haven't been initialized yet
    _clientNameController ??= TextEditingController(text: _client!.clientName);
    _contactNameController ??= TextEditingController(text: _client!.contactName ?? '');
    _contactNumberController ??= TextEditingController(text: _client!.contactNumber ?? '');
    _contactEmailController ??= TextEditingController(text: _client!.contactEmail ?? '');
    _addressController ??= TextEditingController(text: _client!.address ?? '');
    _industrySectorController ??= TextEditingController(text: _client!.industrySector ?? '');
    _contactChannelController ??= TextEditingController(text: _client!.contactChannel ?? '');
    _notesController ??= TextEditingController(text: _client!.notes ?? '');
  }

  @override
  void dispose() {
    _clientNameController?.dispose();
    _contactNameController?.dispose();
    _contactNumberController?.dispose();
    _contactEmailController?.dispose();
    _addressController?.dispose();
    _industrySectorController?.dispose();
    _contactChannelController?.dispose();
    _notesController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFormValidation() {
    // Listen to changes in required fields
    _clientNameController?.addListener(_validateForm);

    // Trigger initial validation after controllers are set up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  void _validateForm() {
    final isValid = _clientNameController?.text.isNotEmpty ?? false;
    print('Form validation: isValid=$isValid, _isFormValid=$_isFormValid');

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
      print('Form validity changed to: $_isFormValid');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Customer')),
        body: Center(
          child: Text(_errorMessage ?? 'Client not found'),
        ),
      );
    }

    return Scaffold(
      body: PatternBackground(
        patternType: PatternType.grid,
        patternOpacity: 0.02,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Customer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Update customer information',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Contact Details'),
                    const SizedBox(height: 16),
                    _buildContactSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Additional Information'),
                    const SizedBox(height: 16),
                    _buildAdditionalSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        ClientFormField(
          controller: _clientNameController!,
          label: 'Company Name',
          hint: 'Enter company name',
          icon: Icons.business,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Company name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ClientFormField(
          controller: _industrySectorController!,
          label: 'Industry Sector',
          hint: 'e.g., Construction, Mining, Manufacturing',
          icon: Icons.work,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        ClientFormField(
          controller: _contactNameController!,
          label: 'Contact Person',
          hint: 'Enter primary contact person name',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ClientFormField(
                controller: _contactEmailController!,
                label: 'Email Address',
                hint: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ClientFormField(
                controller: _contactNumberController!,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClientFormField(
          controller: _contactChannelController!,
          label: 'Contact Channel',
          hint: 'e.g., Phone, Email, WhatsApp, LinkedIn',
          icon: Icons.chat,
        ),
        const SizedBox(height: 16),
        ClientFormField(
          controller: _addressController!,
          label: 'Address',
          hint: 'Enter company address',
          icon: Icons.location_on,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAdditionalSection() {
    return Column(
      children: [
        ClientFormField(
          controller: _notesController!,
          label: 'Notes (Optional)',
          hint: 'Add any additional notes about this customer',
          icon: Icons.note,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Changes will be saved to the database. You can continue to modify their profile and add orders.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                print(
                    'Update button pressed: _isFormValid=$_isFormValid, _isLoading=$_isLoading');
                if (_isFormValid && !_isLoading) {
                  _updateCustomer();
                } else {
                  print('Form is not valid or loading, cannot update');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                      ),
                    )
                  : Text(
                      'Update Customer',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCustomer() async {
    print('Starting customer update process...');

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed, cannot update customer');
      return;
    }

    print('Form validation passed, proceeding with update');

    setState(() {
      _isLoading = true;
    });

    try {
      print('Creating updated customer object...');

      // Create updated customer object
      final updatedCustomer = _client!.copyWith(
        clientName: _clientNameController!.text.trim(),
        contactName: _contactNameController!.text.trim().isEmpty
            ? null
            : _contactNameController!.text.trim(),
        contactNumber: _contactNumberController!.text.trim().isEmpty
            ? null
            : _contactNumberController!.text.trim(),
        contactEmail: _contactEmailController!.text.trim().isEmpty
            ? null
            : _contactEmailController!.text.trim(),
        address: _addressController!.text.trim().isEmpty
            ? null
            : _addressController!.text.trim(),
        industrySector: _industrySectorController!.text.trim().isEmpty
            ? null
            : _industrySectorController!.text.trim(),
        contactChannel: _contactChannelController!.text.trim().isEmpty
            ? null
            : _contactChannelController!.text.trim(),
        notes: _notesController!.text.trim().isEmpty
            ? null
            : _notesController!.text.trim(),
      );

      print('Updated customer data: ${updatedCustomer.clientName}');

      // Update in Supabase database
      print('Saving customer to database...');
      final customerToUpdate = Customer.fromClient(updatedCustomer);
      final savedCustomer =
          await CustomerService.updateCustomer(customerToUpdate);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Customer "${savedCustomer.clientName}" updated successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back with the updated customer
        Navigator.of(context).pop(savedCustomer);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to update customer: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
