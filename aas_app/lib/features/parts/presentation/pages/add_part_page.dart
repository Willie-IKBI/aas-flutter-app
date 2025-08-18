import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/parts_service.dart';
import '../models/part.dart';
import '../widgets/part_form_field.dart';

// Conditional imports for platform-specific file handling
import 'add_part_page_web.dart' if (dart.library.io) 'add_part_page_mobile.dart';

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
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error picking image: $error');
      }
      _showErrorSnackBar('Failed to pick image');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = AddPartPagePlatform.getFileFromImage(image);
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error taking photo: $error');
      }
      _showErrorSnackBar('Failed to take photo');
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
      // Create part object
      final part = Part(
        partName: _nameController.text.trim(),
        partDescription: _descriptionController.text.trim(),
        partNumber: _partNumberController.text.trim(),
        partLocation: _locationController.text.trim(),
        partStatus: 'Active',
        partImageUrl: _imageUrl,
      );

      // Save part to database
      await PartsService.createPart(part);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Part added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error saving part: $error');
      }
      _showErrorSnackBar('Failed to save part: ${PartsService.getErrorMessage(error)}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Part'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
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
                                      Icon(Icons.image, size: 64, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('No image selected'),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showImagePickerDialog,
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('Add Image'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Basic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Information',
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
                              prefixIcon: Icons.inventory_2_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Part name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            PartFormField(
                              controller: _descriptionController,
                              label: 'Description',
                              hint: 'Enter part description',
                              prefixIcon: Icons.description_outlined,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 8),
                            PartFormField(
                              controller: _partNumberController,
                              label: 'Part Number',
                              hint: 'Enter part number',
                              prefixIcon: Icons.qr_code_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Part number is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PartFormField(
                              controller: _locationController,
                              label: 'Location',
                              hint: 'Enter storage location',
                              prefixIcon: Icons.location_on_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Location is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

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
    );
  }
}
