import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user_profile.dart';

class MobileDashboard extends ConsumerStatefulWidget {
  const MobileDashboard({super.key});

  @override
  ConsumerState<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends ConsumerState<MobileDashboard> {
  int _currentIndex = 0;
  UserProfile? _userProfile;

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
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: ResponsiveAppBar(
        title: 'Dashboard',
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      drawer: MobileDrawerNavigation(
        items: _navigationItems,
        userEmail: _userProfile?.email,
        userName: _userProfile?.displayName,
        onSignOut: () async {
          await AuthService.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        },
      ),
      body: _buildDashboardContent(),
      bottomNavigationBar: ResponsiveNavigation(
        items: _navigationItems,
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  (_userProfile?.displayName ?? 'U')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      _userProfile?.displayName ?? 'User',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today is ${DateTime.now().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.add, 'title': 'New Order', 'color': AppColors.primary},
      {
        'icon': Icons.person_add,
        'title': 'New Customer',
        'color': AppColors.success
      },
      {
        'icon': Icons.inventory,
        'title': 'Add Part',
        'color': AppColors.warning
      },
      {'icon': Icons.analytics, 'title': 'Reports', 'color': AppColors.info},
    ];

    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionCard(
                icon: action['icon'] as IconData,
                title: action['title'] as String,
                color: action['color'] as Color,
                onTap: () {
                  // TODO: Handle action tap
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: ResponsiveColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Total Orders',
        'value': '24',
        'icon': Icons.assignment,
        'color': AppColors.primary
      },
      {
        'title': 'Active Orders',
        'value': '8',
        'icon': Icons.pending,
        'color': AppColors.warning
      },
      {
        'title': 'Customers',
        'value': '156',
        'icon': Icons.people,
        'color': AppColors.success
      },
      {
        'title': 'Parts',
        'value': '342',
        'icon': Icons.inventory,
        'color': AppColors.info
      },
    ];

    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildStatCard(
                title: stat['title'] as String,
                value: stat['value'] as String,
                icon: stat['icon'] as IconData,
                color: stat['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: ResponsiveColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'Order #1234 created',
        'time': '2 hours ago',
        'icon': Icons.add_circle
      },
      {
        'title': 'Customer John Doe updated',
        'time': '4 hours ago',
        'icon': Icons.edit
      },
      {
        'title': 'Part ABC123 added to inventory',
        'time': '6 hours ago',
        'icon': Icons.inventory
      },
      {
        'title': 'Order #1230 completed',
        'time': '1 day ago',
        'icon': Icons.check_circle
      },
    ];

    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full activity log
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(
                title: activity['title'] as String,
                time: activity['time'] as String,
                icon: activity['icon'] as IconData,
              )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String time,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
