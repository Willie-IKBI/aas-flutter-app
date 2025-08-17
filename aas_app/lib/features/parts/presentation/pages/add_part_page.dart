import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/index.dart';
import '../models/part.dart';
import '../../data/services/parts_service.dart';
import '../widgets/part_form_field.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  final _partNameController = TextEditingController();
  final _partDescriptionController = TextEditingController();
  final _partLocationController = TextEditingController();
  final _partNumberController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedStatus = 'Active';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _statusOptions = ['Active', 'Inactive', 'Discontinued'];

  @override
  void dispose() {
    _partNameController.dispose();
    _partDescriptionController.dispose();
    _partLocationController.dispose();
    _partNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _savePart() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newPart = Part(
        partName: _partNameController.text.trim(),
        partDescription: _partDescriptionController.text.trim().isEmpty 
            ? null 
            : _partDescriptionController.text.trim(),
        partLocation: _partLocationController.text.trim().isEmpty 
            ? null 
            : _partLocationController.text.trim(),
        partNumber: _partNumberController.text.trim().isEmpty 
            ? null 
            : _partNumberController.text.trim(),
        partStatus: _selectedStatus,
      );

      await PartsService.createPart(newPart, imageFile: _selectedImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newPart.partName} added successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add part: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add New Part',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.onBackground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                             // Basic Information Section
               _buildSectionHeader('Basic Information'),
               const SizedBox(height: 16),
               
               // Image Upload Section
               _buildImageUploadSection(),
               const SizedBox(height: 24),
              
              PartFormField(
                controller: _partNameController,
                label: 'Part Name',
                hint: 'Enter part name',
                prefixIcon: Icons.inventory_2_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Part name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PartFormField(
                controller: _partNumberController,
                label: 'Part Number (SKU)',
                hint: 'Enter part number or SKU',
                prefixIcon: Icons.qr_code_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              PartFormField(
                controller: _partDescriptionController,
                label: 'Description',
                hint: 'Enter part description (optional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              
              // Location & Status Section
              _buildSectionHeader('Location & Status'),
              const SizedBox(height: 16),
              
              PartFormField(
                controller: _partLocationController,
                label: 'Storage Location',
                hint: 'Enter storage location (e.g., Shelf A1, Bin 3)',
                prefixIcon: Icons.location_on_outlined,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              
              // Status Dropdown
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _savePart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Part',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Part Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _removeImage,
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Part Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to select an image',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
