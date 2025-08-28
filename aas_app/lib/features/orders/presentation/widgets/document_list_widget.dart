import 'package:flutter/material.dart';
import '../../../../core/services/document_service.dart';
import '../../../../core/services/notification_service.dart';

class DocumentListWidget extends StatefulWidget {
  final int orderId;
  final Function()? onDocumentDeleted;

  const DocumentListWidget({
    super.key,
    required this.orderId,
    this.onDocumentDeleted,
  });

  @override
  State<DocumentListWidget> createState() => _DocumentListWidgetState();
}

class _DocumentListWidgetState extends State<DocumentListWidget> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await DocumentService.getOrderDocuments(widget.orderId);
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument(int documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
          'Are you sure you want to delete this document? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DocumentService.deleteDocument(documentId);
      if (success) {
        if (mounted) {
          NotificationService.showSuccessNotification(
            context,
            'Document deleted successfully',
          );
        }
        await _loadDocuments();
        widget.onDocumentDeleted?.call();
      } else {
        if (mounted) {
          NotificationService.showErrorNotification(
            context,
            'Failed to delete document',
          );
        }
      }
    }
  }

  void _downloadDocument(String storagePath, String filename) async {
    try {
      final fileBytes = await DocumentService.downloadDocument(storagePath);
      if (fileBytes != null) {
        // In a real app, you would save the file to the device
        // For now, we'll just show a success message
        if (mounted) {
          NotificationService.showSuccessNotification(
            context,
            'Document downloaded: $filename',
          );
        }
      } else {
        if (mounted) {
          NotificationService.showErrorNotification(
            context,
            'Failed to download document',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showErrorNotification(
          context,
          'Error downloading document: $e',
        );
      }
    }
  }

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
                  Icons.folder,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Documents (${_documents.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadDocuments,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_documents.isEmpty)
              _buildEmptyState()
            else
              _buildDocumentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.folder_open,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents uploaded yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload documents to keep them organized with this order',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      children: _documents.map((document) {
        return _buildDocumentCard(document);
      }).toList(),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final filename = document['filename'] as String;
    final category = document['category'] as String;
    final mimeType = document['mime_type'] as String;
    final createdAt = DateTime.parse(document['created_at'] as String);
    final uploadedBy = document['uploaded_by_user'] as Map<String, dynamic>?;
    final storagePath = document['storage_path'] as String;
    final documentId = document['id'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            DocumentService.getFileIcon(mimeType),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(
          filename,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DocumentService.getCategoryDisplayName(category),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            if (uploadedBy != null)
              Text(
                'Uploaded by ${uploadedBy['display_name'] ?? uploadedBy['user_email']}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            Text(
              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'download':
                _downloadDocument(storagePath, filename);
                break;
              case 'delete':
                _deleteDocument(documentId);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _downloadDocument(storagePath, filename),
      ),
    );
  }
}
