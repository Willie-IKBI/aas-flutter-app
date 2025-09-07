import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class PartsSearch extends StatefulWidget {
  const PartsSearch({
    super.key,
    required this.onSearchChanged,
  });
  final Function(String) onSearchChanged;

  @override
  State<PartsSearch> createState() => _PartsSearchState();
}

class _PartsSearchState extends State<PartsSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    widget.onSearchChanged(value);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search parts by name, number, description, or location...',
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          color: AppColors.onBackground,
          fontSize: 14,
        ),
      ),
    );
  }
}
