import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../models/client.dart';
import '../widgets/client_form_field.dart';
import '../../data/services/customer_service.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _clientNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _industrySectorController = TextEditingController();
  final _contactChannelController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _setupFormValidation();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    _contactEmailController.dispose();
    _addressController.dispose();
    _industrySectorController.dispose();
    _contactChannelController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFormValidation() {
    // Listen to changes in required fields
    _clientNameController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _clientNameController.text.isNotEmpty;
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
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
            icon: Icon(
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
                  'Add New Customer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Enter customer information to create a new profile',
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
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
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
          controller: _clientNameController,
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
          controller: _industrySectorController,
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
          controller: _contactNameController,
          label: 'Contact Person',
          hint: 'Enter primary contact person name',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ClientFormField(
                controller: _contactEmailController,
                label: 'Email Address',
                hint: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                controller: _contactNumberController,
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
          controller: _contactChannelController,
          label: 'Contact Channel',
          hint: 'e.g., Phone, Email, WhatsApp, LinkedIn',
          icon: Icons.chat,
        ),
        const SizedBox(height: 16),
        ClientFormField(
          controller: _addressController,
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
          controller: _notesController,
          label: 'Notes (Optional)',
          hint: 'Add any additional notes about this customer',
          icon: Icons.note,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Customer will be created in the database. You can modify their profile and add orders later.',
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
        color: AppColors.surface.withOpacity(0.8),
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
                side: BorderSide(color: AppColors.outline),
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
              onPressed: _isFormValid && !_isLoading ? _saveCustomer : null,
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
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                      ),
                    )
                  : Text(
                      'Save Customer',
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

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create new customer object
      final newCustomer = Client(
        clientName: _clientNameController.text.trim(),
        contactName: _contactNameController.text.trim().isEmpty 
            ? null 
            : _contactNameController.text.trim(),
        contactNumber: _contactNumberController.text.trim().isEmpty 
            ? null 
            : _contactNumberController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty 
            ? null 
            : _contactEmailController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        industrySector: _industrySectorController.text.trim().isEmpty 
            ? null 
            : _industrySectorController.text.trim(),
        contactChannel: _contactChannelController.text.trim().isEmpty 
            ? null 
            : _contactChannelController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      // Save to Supabase database
      final savedCustomer = await CustomerService.createCustomer(newCustomer);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Customer "${savedCustomer.clientName}" created successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success.withOpacity(0.1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back with the saved customer
        Navigator.of(context).pop(savedCustomer);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to create customer: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error.withOpacity(0.1),
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
