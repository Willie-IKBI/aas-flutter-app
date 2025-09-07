import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../models/part.dart';
import '../../../../core/services/parts_service.dart';
import 'parts_card.dart';
import '../pages/part_detail_page.dart';

class PartsList extends StatefulWidget {
  const PartsList({
    super.key,
    required this.searchQuery,
    required this.filterActiveOnly,
  });
  final String searchQuery;
  final bool filterActiveOnly;

  @override
  State<PartsList> createState() => _PartsListState();
}

class _PartsListState extends State<PartsList> {
  List<Part> _parts = [];
  List<Part> _filteredParts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  @override
  void didUpdateWidget(PartsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filterActiveOnly != widget.filterActiveOnly) {
      _filterParts();
    }
  }

  Future<void> _loadParts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final partsData = await PartsService.getAllParts();
      // Convert Map data to Part objects
      final parts = partsData.map((data) => Part.fromJson(data)).toList();

      // Debug: Print each part's image info
      for (final part in parts) {
        print(
            'Part ${part.id}: ${part.partName} - Image: ${part.partImageUrl}');
      }

      setState(() {
        _parts = parts;
        _isLoading = false;
      });
      _filterParts();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterParts() {
    var filtered = _parts;

    // Filter by active status if needed
    if (widget.filterActiveOnly) {
      filtered = filtered.where((part) => part.isActive).toList();
    }

    // Filter by search query
    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((part) {
        final query = widget.searchQuery.toLowerCase();
        return part.partName.toLowerCase().contains(query) ||
            (part.partNumber?.toLowerCase().contains(query) ?? false) ||
            (part.partDescription?.toLowerCase().contains(query) ?? false) ||
            (part.partLocation?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    setState(() {
      _filteredParts = filtered;
    });
  }

  Future<void> _refreshParts() async {
    await _loadParts();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading parts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshParts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredParts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isNotEmpty
                  ? 'No parts found matching "${widget.searchQuery}"'
                  : widget.filterActiveOnly
                      ? 'No active parts found'
                      : 'No parts found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Add your first part to get started',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshParts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredParts.length,
        itemBuilder: (context, index) {
          final part = _filteredParts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PartsCard(
              part: part,
              onTap: () => _viewPart(part),
              onEdit: () => _editPart(part),
              onDelete: () => _deletePart(part),
            ),
          );
        },
      ),
    );
  }

  void _viewPart(Part part) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartDetailPage(partId: part.id.toString()),
      ),
    );
  }

  void _editPart(Part part) {
    // TODO: Navigate to edit part page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${part.partName}'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deletePart(Part part) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Part'),
        content: Text('Are you sure you want to delete "${part.partName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await PartsService.deletePart(part.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${part.partName} deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _refreshParts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete part: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
