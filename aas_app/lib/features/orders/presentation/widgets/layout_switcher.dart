import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ViewLayout {
  list,
  grid,
  kanban,
  table,
  timeline,
  dashboard,
  split,
}

class LayoutSwitcher extends StatelessWidget {
  const LayoutSwitcher({
    super.key,
    required this.currentLayout,
    required this.onLayoutChanged,
    this.availableLayouts = ViewLayout.values,
  });

  final ViewLayout currentLayout;
  final Function(ViewLayout) onLayoutChanged;
  final List<ViewLayout> availableLayouts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableLayouts.map((layout) {
          final isSelected = currentLayout == layout;
          return _buildLayoutButton(context, layout, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildLayoutButton(BuildContext context, ViewLayout layout, bool isSelected) {
    return GestureDetector(
      onTap: () => onLayoutChanged(layout),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getLayoutIcon(layout),
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  IconData _getLayoutIcon(ViewLayout layout) {
    switch (layout) {
      case ViewLayout.list:
        return Icons.view_list;
      case ViewLayout.grid:
        return Icons.grid_view;
      case ViewLayout.kanban:
        return Icons.view_column;
      case ViewLayout.table:
        return Icons.table_view;
      case ViewLayout.timeline:
        return Icons.timeline;
      case ViewLayout.dashboard:
        return Icons.dashboard;
      case ViewLayout.split:
        return Icons.view_sidebar;
    }
  }
}

class LayoutSwitcherDropdown extends StatelessWidget {
  const LayoutSwitcherDropdown({
    super.key,
    required this.currentLayout,
    required this.onLayoutChanged,
    this.availableLayouts = ViewLayout.values,
  });

  final ViewLayout currentLayout;
  final Function(ViewLayout) onLayoutChanged;
  final List<ViewLayout> availableLayouts;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ViewLayout>(
      value: currentLayout,
      onChanged: (ViewLayout? newLayout) {
        if (newLayout != null) {
          onLayoutChanged(newLayout);
        }
      },
      items: availableLayouts.map((layout) {
        return DropdownMenuItem<ViewLayout>(
          value: layout,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getLayoutIcon(layout),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(_getLayoutName(layout)),
            ],
          ),
        );
      }).toList(),
      underline: Container(),
      icon: const Icon(Icons.keyboard_arrow_down),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  IconData _getLayoutIcon(ViewLayout layout) {
    switch (layout) {
      case ViewLayout.list:
        return Icons.view_list;
      case ViewLayout.grid:
        return Icons.grid_view;
      case ViewLayout.kanban:
        return Icons.view_column;
      case ViewLayout.table:
        return Icons.table_view;
      case ViewLayout.timeline:
        return Icons.timeline;
      case ViewLayout.dashboard:
        return Icons.dashboard;
      case ViewLayout.split:
        return Icons.view_sidebar;
    }
  }

  String _getLayoutName(ViewLayout layout) {
    switch (layout) {
      case ViewLayout.list:
        return 'List View';
      case ViewLayout.grid:
        return 'Grid View';
      case ViewLayout.kanban:
        return 'Kanban Board';
      case ViewLayout.table:
        return 'Table View';
      case ViewLayout.timeline:
        return 'Timeline View';
      case ViewLayout.dashboard:
        return 'Dashboard Tiles';
      case ViewLayout.split:
        return 'Split View';
    }
  }
}
