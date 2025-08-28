import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_layout.dart';

class EquipmentPhotosStep extends StatefulWidget {
  final List<dynamic> photos; // Can be File or PlatformFile
  final Function(List<dynamic>) onPhotosChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const EquipmentPhotosStep({
    Key? key,
    required this.photos,
    required this.onPhotosChanged,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  State<EquipmentPhotosStep> createState() => _EquipmentPhotosStepState();
}

class _EquipmentPhotosStepState extends State<EquipmentPhotosStep> {
  bool _isLoading = false;

  Future<void> _pickImage({bool fromCamera = false}) async {
    setState(() => _isLoading = true);
    
    try {
      final files = await PhotoService.pickImage(
        allowMultiple: true,
        fromCamera: fromCamera,
      );
      if (files != null) {
        final newPhotos = List<dynamic>.from(widget.photos);
        
        // Handle single file or multiple files
        if (files is List) {
          newPhotos.addAll(files);
        } else {
          newPhotos.add(files);
        }
        
        // Limit to 10 photos
        if (newPhotos.length > 10) {
          newPhotos.removeRange(10, newPhotos.length);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 10 photos allowed')),
          );
        }
        
        widget.onPhotosChanged(newPhotos);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhoto(int index) {
    final newPhotos = List<dynamic>.from(widget.photos)..removeAt(index);
    widget.onPhotosChanged(newPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPhotoGrid(),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPhotoGrid(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildInfoCard(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(child: _buildPhotoGrid()),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Photos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      fontSize: isMobile ? 20 : 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capture photos of the equipment for documentation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPhotoCount(),
      ],
    );
  }

  Widget _buildPhotoCount() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 16, 
        vertical: isMobile ? 6 : 8
      ),
      decoration: BoxDecoration(
        gradient: AppColors.infoGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${widget.photos.length} photo${widget.photos.length != 1 ? 's' : ''} added',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (widget.photos.isEmpty) {
      return _buildEmptyState();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    int crossAxisCount;
    double childAspectRatio;
    
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoCard(index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'No photos added yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add photos to document the equipment condition',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    final photo = widget.photos[index];
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            _buildPhotoImage(photo),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Photo ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoImage(dynamic photo) {
    if (photo is File) {
      return Image.file(
        photo,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (photo is PlatformFile && photo.bytes != null) {
      return Image.memory(
        Uint8List.fromList(photo.bytes!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildInfoCard() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.infoGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Photo Guidelines',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildGuideline('📸 Take clear, well-lit photos'),
          _buildGuideline('🔍 Include close-ups of any damage'),
          _buildGuideline('📏 Show overall equipment condition'),
          _buildGuideline('🏷️ Capture serial numbers if visible'),
          _buildGuideline('📱 You can add up to 10 photos'),
        ],
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Column(
      children: [
        // Photo capture buttons
        if (isMobile) ...[
          // Mobile: Stacked buttons
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(fromCamera: true),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(fromCamera: false),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.outline),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ] else ...[
          // Desktop/Tablet: Side by side buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImage(fromCamera: true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImage(fromCamera: false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.outline),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onPrevious,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
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
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
