import 'package:flutter/material.dart';
import '../theme/responsive_breakpoints.dart';
import '../theme/index.dart';

/// Responsive app bar that adapts to screen size
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final double? toolbarOpacity;
  final double? bottomOpacity;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.flexibleSpace,
    this.bottom,
    this.titleSpacing,
    this.toolbarOpacity,
    this.bottomOpacity,
    this.onMenuPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: foregroundColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 18 : isTablet ? 20 : 22,
        ),
      ),
      leading: _buildLeading(context, isMobile),
      actions: _buildActions(context, isMobile),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle ?? isMobile,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.onSurface,
      elevation: elevation ?? 1,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      titleSpacing: titleSpacing,
      toolbarOpacity: toolbarOpacity ?? 1.0,
      bottomOpacity: bottomOpacity ?? 1.0,
      toolbarHeight: ResponsiveBreakpoints.getAppBarHeight(context),
    );
  }

  Widget? _buildLeading(BuildContext context, bool isMobile) {
    if (leading != null) return leading;
    
    if (!automaticallyImplyLeading) return null;
    
    // On mobile, show menu button if onMenuPressed is provided
    if (isMobile && onMenuPressed != null) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
        tooltip: 'Menu',
      );
    }
    
    // Show back button if we can pop
    if (Navigator.canPop(context)) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        tooltip: 'Back',
      );
    }
    
    return null;
  }

  List<Widget>? _buildActions(BuildContext context, bool isMobile) {
    if (actions == null || actions!.isEmpty) return null;
    
    // On mobile, limit actions to prevent overflow
    if (isMobile && actions!.length > 2) {
      return [
        ...actions!.take(1),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            // Handle menu selection
          },
          itemBuilder: (context) => actions!
              .skip(1)
              .map((action) => PopupMenuItem<String>(
                    value: 'action',
                    child: action,
                  ))
              .toList(),
        ),
      ];
    }
    
    return actions;
  }

  @override
  Size get preferredSize => const Size.fromHeight(56); // Default height
}

/// Mobile-specific app bar with drawer support
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool showMenuButton;

  const MobileAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuPressed,
    this.onBackPressed,
    this.showBackButton = true,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      leading: _buildLeading(context),
      actions: actions,
      centerTitle: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 1,
      toolbarHeight: ResponsiveBreakpoints.getAppBarHeight(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton && Navigator.canPop(context)) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        tooltip: 'Back',
      );
    }
    
    if (showMenuButton && onMenuPressed != null) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
        tooltip: 'Menu',
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(56); // Default height
}

/// Desktop-specific app bar with more space
class DesktopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DesktopAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: foregroundColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.onSurface,
      elevation: 1,
      toolbarHeight: ResponsiveBreakpoints.getAppBarHeight(context),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56); // Default height
}

/// App bar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Function(String)? onSearch;
  final String? searchHint;
  final bool showSearch;

  const SearchAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onSearch,
    this.searchHint,
    this.showSearch = true,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56); // Default height
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        widget.onSearch?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Search...',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onSearch,
            )
          : Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _toggleSearch,
              tooltip: 'Back',
            )
          : null,
      actions: [
        if (widget.showSearch && !_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
            tooltip: 'Search',
          ),
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSearch,
            tooltip: 'Close',
          ),
        ...?widget.actions,
      ],
      centerTitle: isMobile && !_isSearching,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 1,
      toolbarHeight: ResponsiveBreakpoints.getAppBarHeight(context),
    );
  }
}
