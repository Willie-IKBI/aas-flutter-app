import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/document_service.dart';
import '../../../../core/services/notification_service.dart';

class DocumentUploadWidget extends StatefulWidget {
  final int orderId;
  final Function()? onUploadComplete;

  const DocumentUploadWidget({
    super.key,
    required this.orderId,
    this.onUploadComplete,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  bool _isUploading = false;
  String? _selectedCategory;
  final List<String> _allowedExtensions = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff',
    'txt', 'csv', 'zip', 'rar'
  ];
  final int _maxFileSize = 10 * 1024 * 1024; // 10MB

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Documents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category selection
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Document Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: DocumentService.getDocumentCategories().map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(DocumentService.getCategoryDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedCategory == null || _isUploading
                    ? null
                    : _uploadDocument,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Uploading...' : 'Select File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // File requirements
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'File Requirements',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Maximum file size: ${DocumentService.getFileSize(_maxFileSize)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    '• Allowed formats: ${_allowedExtensions.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
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

  Future<void> _uploadDocument() async {
    if (_selectedCategory == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Pick file
      final result = await DocumentService.pickFile(
        allowedExtensions: _allowedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final file = result.files.first;

      // Validate file
      if (!DocumentService.isValidFile(
        file,
        maxSizeBytes: _maxFileSize,
        allowedExtensions: _allowedExtensions,
      )) {
        final errorMessage = DocumentService.getValidationErrorMessage(
          file,
          maxSizeBytes: _maxFileSize,
          allowedExtensions: _allowedExtensions,
        );
        
        if (mounted) {
          NotificationService.showErrorNotification(context, errorMessage ?? 'Invalid file');
        }
        
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Upload file
      final publicUrl = await DocumentService.uploadOrderDocument(
        orderId: widget.orderId,
        category: _selectedCategory!,
        filename: file.name,
        fileBytes: file.bytes!,
        mimeType: file.extension ?? 'application/octet-stream',
        metadata: {
          'size': file.size,
          'extension': file.extension,
        },
      );

      if (publicUrl != null) {
        if (mounted) {
          NotificationService.showSuccessNotification(
            context,
            'Document uploaded successfully!',
          );
        }
        
        // Call callback if provided
        widget.onUploadComplete?.call();
      } else {
        if (mounted) {
          NotificationService.showErrorNotification(
            context,
            'Failed to upload document. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showErrorNotification(
          context,
          'Error uploading document: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
