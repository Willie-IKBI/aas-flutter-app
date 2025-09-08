import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/parts_service.dart';
import '../../../../core/theme/index.dart';
import '../models/part.dart';
import '../widgets/part_form_field.dart';

// Conditional imports for platform-specific file handling
import 'add_part_page_web.dart'
    if (dart.library.io) 'add_part_page_mobile.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _locationController = TextEditingController();

  // Form state
  dynamic _selectedImage;
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _partNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = AddPartPagePlatform.getFileFromImage(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePart() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final partData = {
        'part_name': _nameController.text.trim(),
        'part_description': _descriptionController.text.trim(),
        'part_number': _partNumberController.text.trim(),
        'part_location': _locationController.text.trim(),
        'part_image_url': _imageUrl,
        'part_status': 'Active',
      };

      await PartsService.createPart(partData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Part created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating part: $e'),
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
    return Scaffold(
      body: PatternBackground(
        patternType: PatternType.grid,
        patternOpacity: 0.02,
        child: Column(
          children: [
            AppBar(
              title: const Text('Add New Part'),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.onBackground,
              elevation: 0,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image Section
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Part Image',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedImage != null)
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: AddPartPagePlatform.buildImageWidget(_selectedImage),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.image, size: 48, color: Colors.grey),
                                              SizedBox(height: 8),
                                              Text('No image selected'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.add_photo_alternate),
                                      label: const Text('Select Image'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Part Details Section
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Part Details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    PartFormField(
                                      controller: _nameController,
                                      label: 'Part Name',
                                      hint: 'Enter part name',
                                      prefixIcon: Icons.inventory_2,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a part name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    PartFormField(
                                      controller: _descriptionController,
                                      label: 'Description',
                                      hint: 'Enter part description',
                                      prefixIcon: Icons.description,
                                      maxLines: 3,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    PartFormField(
                                      controller: _partNumberController,
                                      label: 'Part Number',
                                      hint: 'Enter part number',
                                      prefixIcon: Icons.tag,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a part number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    PartFormField(
                                      controller: _locationController,
                                      label: 'Location',
                                      hint: 'Enter part location',
                                      prefixIcon: Icons.location_on,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a location';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Save Button
                            ElevatedButton(
                              onPressed: _savePart,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Save Part',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
