import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/order_photo.dart';
import '../../../../core/services/stage_management_service.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/theme/index.dart';
import '../providers/pipeline_provider.dart';
import 'photo_gallery.dart';

class StageDetailsModal extends ConsumerStatefulWidget {
  const StageDetailsModal({
    super.key,
    required this.order,
    required this.nextStage,
  });

  final Order order;
  final String nextStage;

  @override
  ConsumerState<StageDetailsModal> createState() => _StageDetailsModalState();
}

class _StageDetailsModalState extends ConsumerState<StageDetailsModal> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<String> _uploadedPhotos = [];
  List<OrderPhoto> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await PhotoService.getOrderPhotos(widget.order.id);
      setState(() {
        _photos = photos;
        _uploadedPhotos = photos.map((p) => p.id.toString()).toList();
      });
    } catch (error) {
      // Handle error silently for now
      setState(() {
        _photos = [];
        _uploadedPhotos = [];
      });
    }
  }

  Future<void> _pickAndUploadPhotos() async {
    try {
      final files = await PhotoService.pickImage(
        allowMultiple: true,
        fromCamera: false,
      );

      if (files != null) {
        final fileList = files is List ? files : [files];
        
        for (final file in fileList) {
          try {
            await PhotoService.uploadOrderPhoto(
              orderId: widget.order.id,
              photoFile: file,
              photoName: 'Stage Photo ${_photos.length + 1}',
              photoDescription: 'Uploaded during stage transition',
            );
          } catch (e) {
            // Handle individual upload errors silently
          }
        }
        
        // Refresh photos
        _loadPhotos();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully uploaded ${fileList.length} photo${fileList.length != 1 ? 's' : ''}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photos: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(OrderPhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final success = await PhotoService.deleteOrderPhoto(photo.id);
        if (success) {
          _loadPhotos();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo deleted successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting photo: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showPhotoDialog(OrderPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        photo.photoName ?? 'Stage Photo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: InteractiveViewer(
                    child: Image.network(
                      photo.photoUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPhotoSection() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      height: isMobile ? 100 : 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: _photos.isEmpty ? _buildEmptyPhotoState() : _buildPhotoThumbnails(),
    );
  }

  Widget _buildEmptyPhotoState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 32,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No photos yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickAndUploadPhotos,
            icon: const Icon(Icons.add_a_photo, size: 16),
            label: const Text('Add Photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnails() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final thumbnailSize = isMobile ? 60.0 : 80.0;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Photo thumbnails
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _showPhotoDialog(photo),
                    child: Container(
                      width: thumbnailSize,
                      height: thumbnailSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              photo.photoUrl,
                              width: thumbnailSize,
                              height: thumbnailSize,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppColors.surfaceVariant,
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                            // Delete button
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _deletePhoto(photo),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Add photos button
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _pickAndUploadPhotos,
            icon: const Icon(Icons.add_a_photo, size: 16),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeStage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Move order to next stage with notes
      final success = await StageManagementService.moveOrderToStage(
        widget.order.id,
        widget.nextStage,
        notes: _notesController.text.trim(),
        payload: {
          'photos_count': _uploadedPhotos.length,
          'completed_at': DateTime.now().toIso8601String(),
        },
      );

      if (success && mounted) {
        // Refresh the pipeline
        ref.invalidate(pipelineProvider);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order moved to ${StageManagementService.getStageDisplayName(widget.nextStage)}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Close modal
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Calculate responsive modal dimensions
    final modalWidth = isMobile ? screenWidth * 0.95 : screenWidth * 0.7;
    final modalHeight = isMobile ? screenHeight * 0.9 : screenHeight * 0.8;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: modalWidth,
        height: modalHeight,
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: screenHeight * 0.95,
          minHeight: isMobile ? 400 : 500,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header (Fixed)
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Stage',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${widget.order.id} → ${StageManagementService.getStageDisplayName(widget.nextStage)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            // Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current Stage Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stage Transition',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${StageManagementService.getStageDisplayName(widget.order.currentStage.toDatabaseString())} → ${StageManagementService.getStageDisplayName(widget.nextStage)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Notes Section
                      Row(
                        children: [
                          Text(
                            'Stage Notes',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Required',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: isMobile ? 3 : 4,
                        decoration: InputDecoration(
                          hintText: 'Describe what was completed in this stage...',
                          hintStyle: TextStyle(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: TextStyle(
                          color: AppColors.onSurface,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please add notes about this stage';
                          }
                          if (value.trim().length < 10) {
                            return 'Please provide more detailed notes (at least 10 characters)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Photos Section
                      Row(
                        children: [
                          Text(
                            'Stage Photos',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_photos.length} photo${_photos.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCompactPhotoSection(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Footer with Action Buttons
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outline.withValues(alpha: 0.2),
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.outline.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _completeStage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_forward, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Complete Stage',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
}
