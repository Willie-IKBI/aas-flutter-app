import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/user_profile.dart';
import '../providers/dashboard_providers.dart';
import '../../../admin/presentation/pages/user_management_page.dart';
import '../../../orders/presentation/pages/active_jobs_page.dart';

class ExecutiveDashboard extends ConsumerWidget {
  const ExecutiveDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassignedUsersAsync = ref.watch(unassignedUsersProvider);
    final orderStatsAsync = ref.watch(orderStatisticsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop
              ? 32.0
              : isTablet
                  ? 24.0
                  : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDesktop),
              const SizedBox(height: 32),

              // Statistics Cards
              _buildStatisticsSection(
                  context, orderStatsAsync, isDesktop, isTablet),
              const SizedBox(height: 32),

              // Unassigned Users Section
              _buildUnassignedUsersSection(
                  context, unassignedUsersAsync, isDesktop, isTablet),
              const SizedBox(height: 32),

              // Quick Actions
              _buildQuickActionsSection(context, isDesktop, isTablet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Executive Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overview of system performance and user management',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context,
      AsyncValue<int> orderStatsAsync, bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        orderStatsAsync.when(
          data: (activeOrdersCount) => _buildStatisticsCards(
              context, activeOrdersCount, isDesktop, isTablet),
          loading: () => _buildLoadingCards(context, isDesktop, isTablet),
          error: (error, stack) => _buildErrorCard(
              context, 'Failed to load order statistics: $error'),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(BuildContext context, int activeOrdersCount,
      bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop
          ? 4
          : isTablet
              ? 2
              : 1,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 2.5 : 2.0,
      children: [
        _buildStatCard(
          context,
          'Active Orders',
          activeOrdersCount.toString(),
          Icons.assignment,
          AppColors.primary,
        ),
        _buildStatCard(
          context,
          'Completed Orders',
          '0', // Placeholder
          Icons.check_circle,
          AppColors.success,
        ),
        _buildStatCard(
          context,
          'Pending Orders',
          '0', // Placeholder
          Icons.pending,
          AppColors.warning,
        ),
        _buildStatCard(
          context,
          'Total Revenue',
          r'$0', // Placeholder
          Icons.attach_money,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildLoadingCards(
      BuildContext context, bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop
          ? 4
          : isTablet
              ? 2
              : 1,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 2.5 : 2.0,
      children: List.generate(4, (index) => _buildLoadingCard(context)),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedUsersSection(
      BuildContext context,
      AsyncValue<List<UserProfile>> unassignedUsersAsync,
      bool isDesktop,
      bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unassigned Users',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementPage(),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Manage Users'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        unassignedUsersAsync.when(
          data: (users) => _buildUsersList(context, users, isDesktop, isTablet),
          loading: () => _buildUsersLoading(context),
          error: (error, stack) =>
              _buildErrorCard(context, 'Failed to load users: $error'),
        ),
      ],
    );
  }

  Widget _buildUsersList(BuildContext context, List<UserProfile> users,
      bool isDesktop, bool isTablet) {
    if (users.isEmpty) {
      return _buildEmptyUsersCard(context);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ...users.take(5).map((user) => _buildUserTile(context, user)),
          if (users.length > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'And ${users.length - 5} more users...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyUsersCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No unassigned users',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'All users have been assigned to appropriate roles.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserProfile user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          user.displayName?.isNotEmpty ?? false
              ? user.displayName![0].toUpperCase()
              : (user.email?[0] ?? 'U').toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.displayName?.isNotEmpty ?? false ? user.displayName! : (user.email ?? '—'),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        user.email ?? '—',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
      trailing: Text(
        user.role.name.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildQuickActionsSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop
              ? 3
              : isTablet
                  ? 2
                  : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isDesktop ? 2.0 : 1.5,
          children: [
            _buildActionCard(
              context,
              'View All Orders',
              Icons.assignment,
              AppColors.primary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActiveJobsPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              'Manage Users',
              Icons.people,
              AppColors.info,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              'System Settings',
              Icons.settings,
              AppColors.warning,
              () {
                // TODO: Implement system settings
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
