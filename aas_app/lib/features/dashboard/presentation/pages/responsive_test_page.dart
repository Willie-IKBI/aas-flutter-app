import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';

class ResponsiveTestPage extends ConsumerStatefulWidget {
  const ResponsiveTestPage({super.key});

  @override
  ConsumerState<ResponsiveTestPage> createState() => _ResponsiveTestPageState();
}

class _ResponsiveTestPageState extends ConsumerState<ResponsiveTestPage> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
      isActive: true,
    ),
    const NavigationItem(
      title: 'Orders',
      icon: Icons.assignment,
      route: '/orders',
    ),
    const NavigationItem(
      title: 'Customers',
      icon: Icons.people,
      route: '/customers',
    ),
    const NavigationItem(
      title: 'Parts',
      icon: Icons.inventory,
      route: '/parts',
    ),
    const NavigationItem(
      title: 'Users',
      icon: Icons.manage_accounts,
      route: '/users',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: ResponsiveAppBar(
        title: 'Responsive Test',
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: ResponsiveBreakpoints.isMobile(context)
          ? MobileDrawerNavigation(
              items: _navigationItems,
              userEmail: 'test@example.com',
              userName: 'Test User',
              onSignOut: () {},
            )
          : null,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      bottomNavigationBar: ResponsiveBreakpoints.isMobile(context)
          ? ResponsiveNavigation(
              items: _navigationItems,
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        children: [
          _buildInfoCard('Mobile Layout', 'This is the mobile-first design'),
          _buildInfoCard('Screen Size', 'Mobile: ${ResponsiveBreakpoints.mobileLarge}px'),
          _buildInfoCard('Grid Columns', '1 column layout'),
          _buildInfoCard('Navigation', 'Bottom navigation bar'),
          _buildInfoCard('App Bar', 'Centered title with menu'),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return ResponsiveContainer(
      child: ResponsiveGrid(
        children: [
          _buildInfoCard('Tablet Layout', 'This is the tablet design'),
          _buildInfoCard('Screen Size', 'Tablet: ${ResponsiveBreakpoints.tabletLarge}px'),
          _buildInfoCard('Grid Columns', '2 column layout'),
          _buildInfoCard('Navigation', 'Sidebar navigation'),
          _buildInfoCard('App Bar', 'Left-aligned title'),
          _buildInfoCard('Spacing', 'Increased padding and margins'),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return ResponsiveContainer(
      child: ResponsiveGrid(
        children: [
          _buildInfoCard('Desktop Layout', 'This is the desktop design'),
          _buildInfoCard('Screen Size', 'Desktop: ${ResponsiveBreakpoints.desktopMedium}px'),
          _buildInfoCard('Grid Columns', '3 column layout'),
          _buildInfoCard('Navigation', 'Full sidebar navigation'),
          _buildInfoCard('App Bar', 'Large title and actions'),
          _buildInfoCard('Spacing', 'Maximum padding and margins'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          Icon(
            Icons.info_outline,
            size: ResponsiveBreakpoints.getIconSize(context),
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
