import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/theme/app_colors.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    this.customer,
    this.equipmentType,
    this.equipmentModel,
    this.equipmentSerialNumber,
    required this.jobDescription,
    this.photos = const [],
    this.salesRep,
    required this.orderDate,
  });
  final Customer? customer;
  final String? equipmentType;
  final String? equipmentModel;
  final String? equipmentSerialNumber;
  final String jobDescription;
  final List<dynamic> photos; // Can be File or PlatformFile
  final UserProfile? salesRep;
  final DateTime orderDate;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Review all details before creating the order',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information
                  _buildSection(
                    context,
                    'Customer Information',
                    Icons.person,
                    [
                      _buildInfoRow('Client Name',
                          customer?.clientName ?? 'Not selected'),
                      if (customer?.contactName != null)
                        _buildInfoRow('Contact Person', customer!.contactName!),
                      if (customer?.contactEmail != null)
                        _buildInfoRow('Email', customer!.contactEmail!),
                      if (customer?.contactNumber != null)
                        _buildInfoRow('Phone', customer!.contactNumber!),
                      if (customer?.address != null)
                        _buildInfoRow('Address', customer!.address!),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Order Information
                  _buildSection(
                    context,
                    'Order Information',
                    Icons.receipt,
                    [
                      _buildInfoRow('Order Date',
                          '${orderDate.day}/${orderDate.month}/${orderDate.year}'),
                      _buildInfoRow(
                          'Job Description',
                          jobDescription.isNotEmpty
                              ? jobDescription
                              : 'Not provided'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Equipment Information
                  _buildSection(
                    context,
                    'Equipment Information',
                    Icons.build,
                    [
                      if (equipmentType != null && equipmentType!.isNotEmpty)
                        _buildInfoRow('Equipment Type', equipmentType!),
                      if (equipmentModel != null && equipmentModel!.isNotEmpty)
                        _buildInfoRow('Equipment Model', equipmentModel!),
                      if (equipmentSerialNumber != null &&
                          equipmentSerialNumber!.isNotEmpty)
                        _buildInfoRow('Serial Number', equipmentSerialNumber!),
                      if ((equipmentType == null || equipmentType!.isEmpty) &&
                          (equipmentModel == null || equipmentModel!.isEmpty) &&
                          (equipmentSerialNumber == null ||
                              equipmentSerialNumber!.isEmpty))
                        _buildInfoRow('Equipment Details', 'Not provided'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Equipment Photos
                  _buildSection(
                    context,
                    'Equipment Photos',
                    Icons.camera_alt,
                    [
                      _buildInfoRow(
                        'Photos Added',
                        '${photos.length} photo${photos.length != 1 ? 's' : ''}',
                      ),
                      if (photos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildPhotoPreview(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sales Representative
                  _buildSection(
                    context,
                    'Sales Representative',
                    Icons.people,
                    [
                      _buildInfoRow(
                        'Assigned Rep',
                        salesRep?.displayName ?? 'Not assigned',
                      ),
                      if (salesRep?.email != null)
                        _buildInfoRow('Email', salesRep!.email!),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.infoGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.info.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.onInfo.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: AppColors.onInfo,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Order Summary',
                                style: TextStyle(
                                  color: AppColors.onInfo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This order will be created with the status "In Progress" and will start at the "Order Captured" stage. The assigned sales representative will be notified of the new order.',
                          style: TextStyle(
                            color: AppColors.onInfo,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildPhotoImage(photos[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoImage(dynamic photo) {
    if (photo is File) {
      return Image.file(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const ColoredBox(
            color: AppColors.surfaceVariant,
            child: Center(
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
              ),
            ),
          );
        },
      );
    } else if (photo is PlatformFile && photo.bytes != null) {
      return Image.memory(
        Uint8List.fromList(photo.bytes!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const ColoredBox(
            color: AppColors.surfaceVariant,
            child: Center(
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
              ),
            ),
          );
        },
      );
    } else {
      return const ColoredBox(
        color: AppColors.surfaceVariant,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: AppColors.error,
          ),
        ),
      );
    }
  }
}
