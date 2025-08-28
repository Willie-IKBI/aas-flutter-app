import 'package:flutter/material.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/clients/data/services/customer_service.dart';
import '../../../../features/clients/presentation/models/client.dart';

class CustomerDetailsModal extends StatefulWidget {
  const CustomerDetailsModal({super.key});

  @override
  State<CustomerDetailsModal> createState() => _CustomerDetailsModalState();
}

class _CustomerDetailsModalState extends State<CustomerDetailsModal> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _industrySectorController = TextEditingController();
  final _contactChannelController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;

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
    super.dispose();
  }

  Future<void> _createCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Client(
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
      
      final createdClient = await CustomerService.createCustomer(client);
      final customer = Customer.fromClient(createdClient);

      if (customer != null && mounted) {
        Navigator.of(context).pop(customer);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create customer. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isDesktop ? 600 : MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: AppColors.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Create New Customer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.onPrimary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.onPrimary.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client Name (Required)
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _clientNameController,
                        label: 'Client Name *',
                        hint: 'Enter company or client name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Client name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Contact Information
                      _buildSectionHeader('Contact Information'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _contactNameController,
                              label: 'Contact Name',
                              hint: 'Primary contact person',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _contactNumberController,
                              label: 'Phone Number',
                              hint: 'Contact phone number',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _contactEmailController,
                        label: 'Email Address',
                        hint: 'Contact email address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Business address',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Additional Information
                      _buildSectionHeader('Additional Information'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _industrySectorController,
                              label: 'Industry Sector',
                              hint: 'e.g., Construction, Mining',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _contactChannelController,
                              label: 'Preferred Contact',
                              hint: 'e.g., Phone, Email, WhatsApp',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes',
                        hint: 'Additional notes about the customer',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.glassGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createCustomer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Create Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.infoGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
        hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: AppColors.onSurface),
      validator: validator,
    );
  }
}

