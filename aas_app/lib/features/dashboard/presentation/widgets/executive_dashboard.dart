import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/order.dart';
import '../providers/dashboard_providers.dart';
import '../../../admin/presentation/pages/user_management_page.dart';
import '../../../orders/presentation/pages/active_jobs_page.dart';

class ExecutiveDashboard extends ConsumerWidget {
  const ExecutiveDashboard({super.key});

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

              // Main Dashboard Grid
              _buildMainGrid(context, unassignedUsersAsync, activeOrdersAsync, isDesktop, isTablet, isMobile),
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
                  Expanded(child: _buildCompactMetricCard(context, 'Completed', '0', Icons.check_circle, AppColors.success)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCompactMetricCard(context, 'Pending', '0', Icons.pending, AppColors.warning)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'Revenue', r'$0', Icons.attach_money, AppColors.info)),
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
                  'Completed',
                  '0',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Pending',
                  '0',
                  Icons.pending,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Revenue',
                  r'$0',
                  Icons.attach_money,
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

  Widget _buildMainGrid(BuildContext context, AsyncValue<List<UserProfile>> unassignedUsersAsync, 
      AsyncValue<List<Order>> activeOrdersAsync, bool isDesktop, bool isTablet, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            height: 350, // Fixed height for mobile active orders
            child: _buildActiveOrdersWidget(context, activeOrdersAsync),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // Fixed height for mobile user management
            child: _buildUserManagementWidget(context, unassignedUsersAsync),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250, // Fixed height for mobile quick actions
            child: _buildQuickActionsWidget(context),
          ),
        ],
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 3 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.2 : 1.0,
      children: [
        _buildActiveOrdersWidget(context, activeOrdersAsync),
        _buildUserManagementWidget(context, unassignedUsersAsync),
        _buildQuickActionsWidget(context),
      ],
    );
  }

  Widget _buildActiveOrdersWidget(BuildContext context, AsyncValue<List<Order>> activeOrdersAsync) {
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
              Icon(Icons.assignment, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Active Orders',
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
                      builder: (context) => const ActiveJobsPage(),
                    ),
                  );
                },
                child: Text('View All', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: activeOrdersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 32, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          'No active orders',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: orders.length > 5 ? 5 : orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                ),
                                if (order.customerName != null)
                                  Text(
                                    order.customerName!,
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
                              color: _getStatusColor(order.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toDisplayString().toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getStatusColor(order.status),
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
                      'Failed to load orders',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
              data: (users) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      users.isEmpty ? Icons.check_circle : Icons.warning,
                      size: 32,
                      color: users.isEmpty ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      users.isEmpty ? 'All users assigned' : '${users.length} unassigned users',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: users.isEmpty ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (users.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Review and assign roles',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _buildQuickActionsWidget(BuildContext context) {
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
              Icon(Icons.flash_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                _buildActionButton(
                  context,
                  'New Order',
                  Icons.add_circle_outline,
                  AppColors.primary,
                  () {
                    // TODO: Navigate to new order page
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  context,
                  'Add Customer',
                  Icons.person_add,
                  AppColors.info,
                  () {
                    // TODO: Navigate to add customer page
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  context,
                  'View Reports',
                  Icons.analytics,
                  AppColors.success,
                  () {
                    // TODO: Navigate to reports page
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  context,
                  'Export Data',
                  Icons.download,
                  AppColors.warning,
                  () {
                    // TODO: Export data functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, 
      Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 18),
        label: Text(
          title,
          style: TextStyle(color: AppColors.onSurface),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          backgroundColor: color.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return AppColors.statusDraft;
      case OrderStatus.inProgress:
        return AppColors.statusInProgress;
      case OrderStatus.waitingApproval:
        return AppColors.statusWaitingApproval;
      case OrderStatus.approved:
        return AppColors.statusApproved;
      case OrderStatus.inProduction:
        return AppColors.statusInProduction;
      case OrderStatus.complete:
        return AppColors.statusComplete;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }
}