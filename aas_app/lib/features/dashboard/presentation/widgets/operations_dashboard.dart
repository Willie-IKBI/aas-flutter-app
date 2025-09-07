import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/order.dart';
import '../providers/dashboard_providers.dart';
import '../../../admin/presentation/pages/user_management_page.dart';
import '../../../orders/presentation/widgets/pipeline_board.dart';
import '../../../orders/presentation/providers/pipeline_provider.dart';

class OperationsDashboard extends ConsumerWidget {
  const OperationsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassignedUsersAsync = ref.watch(unassignedUsersProvider);
    final orderStatsAsync = ref.watch(orderStatisticsProvider);
    final activeOrdersAsync = ref.watch(activeOrdersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.0 : isTablet ? 20.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDesktop),
              const SizedBox(height: 24),

              // Key Metrics Bar
              _buildKeyMetricsBar(context, orderStatsAsync, activeOrdersAsync, isDesktop, isTablet, isMobile),
              const SizedBox(height: 24),

              // Main Content Grid
              _buildMainContent(context, unassignedUsersAsync, isDesktop, isTablet, isMobile),
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
          'Operations Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage orders, users, and operational workflows',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsBar(BuildContext context, AsyncValue<int> orderStatsAsync, 
      AsyncValue<List<Order>> activeOrdersAsync, bool isDesktop, bool isTablet, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: isMobile 
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildCompactMetricCard(context, 'Active Orders', activeOrdersAsync.when(
                    data: (orders) => orders.length.toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ), Icons.assignment, AppColors.primary)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'Pending Approval', '0', Icons.pending_actions, AppColors.warning)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCompactMetricCard(context, 'Completed Today', '0', Icons.check_circle, AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'Total Orders', '0', Icons.assignment_turned_in, AppColors.info)),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Active Orders',
                  activeOrdersAsync.when(
                    data: (orders) => orders.length.toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  Icons.assignment,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Pending Approval',
                  '0',
                  Icons.pending_actions,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Completed Today',
                  '0',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Total Orders',
                  '0',
                  Icons.assignment_turned_in,
                  AppColors.info,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCompactMetricCard(BuildContext context, String title, String value, 
      IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, AsyncValue<List<UserProfile>> unassignedUsersAsync, 
      bool isDesktop, bool isTablet, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            height: 400, // Fixed height for mobile pipeline
            child: _buildPipelineWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Fixed height for mobile user management
            child: _buildUserManagementWidget(context, unassignedUsersAsync),
          ),
        ],
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 2 : 1,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.2 : 1.0,
      children: [
        _buildPipelineWidget(context),
        _buildUserManagementWidget(context, unassignedUsersAsync),
      ],
    );
  }

  Widget _buildPipelineWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Job Pipeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
              const Spacer(),
              _buildViewToggle(context),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              ),
              child: const PipelineBoard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final viewMode = ref.watch(viewModeProvider);
        
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                context,
                ref,
                icon: Icons.view_kanban,
                isSelected: viewMode == PipelineViewMode.horizontal,
                onTap: () => ref.read(pipelineProvider.notifier).setViewMode(PipelineViewMode.horizontal),
                tooltip: 'Horizontal View',
              ),
              _buildToggleButton(
                context,
                ref,
                icon: Icons.grid_view,
                isSelected: viewMode == PipelineViewMode.grid,
                onTap: () => ref.read(pipelineProvider.notifier).setViewMode(PipelineViewMode.grid),
                tooltip: 'Grid View',
              ),
              _buildToggleButton(
                context,
                ref,
                icon: Icons.list,
                isSelected: viewMode == PipelineViewMode.mobile,
                onTap: () => ref.read(pipelineProvider.notifier).setViewMode(PipelineViewMode.mobile),
                tooltip: 'List View',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected 
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildUserManagementWidget(BuildContext context, AsyncValue<List<UserProfile>> unassignedUsersAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'User Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserManagementPage(),
                    ),
                  );
                },
                child: Text('Manage', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: unassignedUsersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 32,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All users assigned',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No action required',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: users.length > 5 ? 5 : users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                            child: Text(
                              user.displayName?.isNotEmpty ?? false
                                  ? user.displayName![0].toUpperCase()
                                  : (user.email?.isNotEmpty ?? false) 
                                      ? user.email![0].toUpperCase()
                                      : '?',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName?.isNotEmpty ?? false 
                                      ? user.displayName! 
                                      : user.email ?? '—',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                ),
                                Text(
                                  user.email ?? '—',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'UNASSIGNED',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 32, color: AppColors.error),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load users',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (unassignedUsersAsync.hasValue && unassignedUsersAsync.value!.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserManagementPage(),
                    ),
                  );
                },
                child: Text(
                  'View All Users',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}