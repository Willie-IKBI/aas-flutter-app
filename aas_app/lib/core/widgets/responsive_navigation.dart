import 'package:flutter/material.dart';
import '../theme/responsive_breakpoints.dart';
import '../theme/index.dart';

/// Navigation item for responsive navigation
class NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isActive;
  final VoidCallback? onTap;
  final List<NavigationItem>? children;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isActive = false,
    this.onTap,
    this.children,
  });
}

/// Mobile bottom navigation bar
class MobileBottomNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const MobileBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedItemColor: selectedItemColor ?? AppColors.primary,
      unselectedItemColor: unselectedItemColor ?? AppColors.onSurfaceVariant,
      selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      items: items.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.title,
      )).toList(),
    );
  }
}

/// Mobile drawer navigation
class MobileDrawerNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final String? userEmail;
  final String? userName;
  final VoidCallback? onSignOut;
  final VoidCallback? onProfileTap;

  const MobileDrawerNavigation({
    super.key,
    required this.items,
    this.userEmail,
    this.userName,
    this.onSignOut,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // User header
          _buildUserHeader(context),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...items.map((item) => _buildNavigationItem(context, item)),
              ],
            ),
          ),
          
          // Sign out button
          if (onSignOut != null) _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        userName ?? 'User',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      accountEmail: Text(
        userEmail ?? 'user@example.com',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          (userName ?? 'U').substring(0, 1).toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      onDetailsPressed: onProfileTap,
    );
  }

  Widget _buildNavigationItem(BuildContext context, NavigationItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.isActive ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
      title: Text(
        item.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: item.isActive ? AppColors.primary : AppColors.onSurface,
          fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: item.isActive,
      onTap: item.onTap,
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error),
      title: Text(
        'Sign Out',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onSignOut,
    );
  }
}

/// Desktop sidebar navigation
class DesktopSidebarNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final String? userEmail;
  final String? userName;
  final VoidCallback? onSignOut;
  final VoidCallback? onProfileTap;
  final bool isCollapsed;

  const DesktopSidebarNavigation({
    super.key,
    required this.items,
    this.userEmail,
    this.userName,
    this.onSignOut,
    this.onProfileTap,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = ResponsiveBreakpoints.getSidebarWidth(context);
    
    return Container(
      width: isCollapsed ? 72 : sidebarWidth,
      color: AppColors.surface,
      child: Column(
        children: [
          // User header
          _buildUserHeader(context),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...items.map((item) => _buildNavigationItem(context, item)),
              ],
            ),
          ),
          
          // Sign out button
          if (onSignOut != null) _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: isCollapsed
          ? CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                (userName ?? 'U').substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (userName ?? 'U').substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? 'User',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail ?? 'user@example.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNavigationItem(BuildContext context, NavigationItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        size: isCollapsed ? 24 : 20,
      ),
      title: isCollapsed
          ? null
          : Text(
              item.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: item.isActive ? AppColors.primary : AppColors.onSurface,
                fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
      selected: item.isActive,
      onTap: item.onTap,
      dense: isCollapsed,
      contentPadding: isCollapsed
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error),
      title: isCollapsed
          ? null
          : Text(
              'Sign Out',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
      onTap: onSignOut,
      dense: isCollapsed,
      contentPadding: isCollapsed
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

/// Responsive navigation wrapper
class ResponsiveNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final String? userEmail;
  final String? userName;
  final VoidCallback? onSignOut;
  final VoidCallback? onProfileTap;
  final bool showDrawer;

  const ResponsiveNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onIndexChanged,
    this.userEmail,
    this.userName,
    this.onSignOut,
    this.onProfileTap,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    
    if (isMobile) {
      return MobileBottomNavigation(
        items: items,
        currentIndex: currentIndex,
        onTap: onIndexChanged,
      );
    }
    
    return DesktopSidebarNavigation(
      items: items,
      userEmail: userEmail,
      userName: userName,
      onSignOut: onSignOut,
      onProfileTap: onProfileTap,
    );
  }
}

/// Navigation drawer for mobile
class NavigationDrawer extends StatelessWidget {
  final List<NavigationItem> items;
  final String? userEmail;
  final String? userName;
  final VoidCallback? onSignOut;
  final VoidCallback? onProfileTap;

  const NavigationDrawer({
    super.key,
    required this.items,
    this.userEmail,
    this.userName,
    this.onSignOut,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return MobileDrawerNavigation(
      items: items,
      userEmail: userEmail,
      userName: userName,
      onSignOut: onSignOut,
      onProfileTap: onProfileTap,
    );
  }
}
