import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/models/order.dart';
import '../providers/dashboard_providers.dart';
import '../../../clients/presentation/pages/client_management_page.dart';

class SalesDashboard extends ConsumerWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _buildKeyMetricsBar(context, isDesktop, isTablet, isMobile),
              const SizedBox(height: 24),

              // Main Content Grid
              _buildMainContent(context, activeOrdersAsync, isDesktop, isTablet, isMobile),
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
          'Sales & Customer Hub',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customer management and sales pipeline',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsBar(BuildContext context, bool isDesktop, bool isTablet, bool isMobile) {
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
                  Expanded(child: _buildCompactMetricCard(context, 'Monthly Sales', 'R89,500', Icons.trending_up, AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'New Customers', '12', Icons.person_add, AppColors.info)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCompactMetricCard(context, 'Conversion Rate', '68%', Icons.analytics, AppColors.primary)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'Avg Deal Size', 'R7,450', Icons.attach_money, AppColors.secondary)),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Monthly Sales',
                  'R89,500',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'New Customers',
                  '12',
                  Icons.person_add,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Conversion Rate',
                  '68%',
                  Icons.analytics,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Avg Deal Size',
                  'R7,450',
                  Icons.attach_money,
                  AppColors.secondary,
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

  Widget _buildMainContent(BuildContext context, AsyncValue<List<Order>> activeOrdersAsync, 
      bool isDesktop, bool isTablet, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            height: 200, // Fixed height for mobile quick actions
            child: _buildQuickActionsWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Fixed height for mobile order pipeline
            child: _buildOrderPipelineWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Fixed height for mobile customer management
            child: _buildCustomerManagementWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250, // Fixed height for mobile revenue tracking
            child: _buildRevenueTrackingWidget(context),
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
        _buildQuickActionsWidget(context),
        _buildOrderPipelineWidget(context),
        _buildCustomerManagementWidget(context),
        _buildRevenueTrackingWidget(context),
      ],
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
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  context,
                  'Manage Clients',
                  Icons.people_outline,
                  AppColors.primary,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientManagementPage(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Create Quote',
                  Icons.description,
                  AppColors.info,
                  () {
                    // TODO: Navigate to create quote
                  },
                ),
                _buildActionButton(
                  context,
                  'Follow Up',
                  Icons.phone,
                  AppColors.secondary,
                  () {
                    // TODO: Navigate to follow up
                  },
                ),
                _buildActionButton(
                  context,
                  'Schedule Meeting',
                  Icons.calendar_today,
                  AppColors.success,
                  () {
                    // TODO: Navigate to schedule meeting
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
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderPipelineWidget(BuildContext context) {
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
                'Order Pipeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildPipelineItem(context, 'New Quotes', '8', 'R45,200', AppColors.info, Icons.description),
                _buildPipelineItem(context, 'Pending Approval', '5', 'R32,800', AppColors.warning, Icons.pending),
                _buildPipelineItem(context, 'Negotiation', '3', 'R28,500', AppColors.secondary, Icons.handshake),
                _buildPipelineItem(context, 'Ready to Close', '2', 'R18,900', AppColors.success, Icons.check_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem(BuildContext context, String stage, String count, 
      String value, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count orders • $value',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.onSurfaceVariant, size: 14),
        ],
      ),
    );
  }

  Widget _buildCustomerManagementWidget(BuildContext context) {
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
                'Customer Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientManagementPage(),
                    ),
                  );
                },
                child: Text('View All', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildCustomerItem(context, 'ABC Construction', 'Active', '2 days ago', 'R12,450', 'High', AppColors.success),
                _buildCustomerItem(context, 'XYZ Mining', 'Active', '1 week ago', 'R8,900', 'Medium', AppColors.info),
                _buildCustomerItem(context, 'DEF Contractors', 'Inactive', '3 weeks ago', 'R5,200', 'Low', AppColors.warning),
                _buildCustomerItem(context, 'GHI Industries', 'Prospect', 'Never', 'R0', 'High', AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerItem(BuildContext context, String name, String status, 
      String lastOrder, String totalSpent, String priority, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priority,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$status • Last order: $lastOrder',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total spent: $totalSpent',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrackingWidget(BuildContext context) {
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
              Icon(Icons.trending_up, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Revenue Tracking',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.8,
              children: [
                _buildRevenueCard(context, 'This Month', 'R89,500', '+15.2%', true, AppColors.success),
                _buildRevenueCard(context, 'Last Month', 'R77,800', '+8.7%', true, AppColors.info),
                _buildRevenueCard(context, 'This Quarter', 'R245,200', '+12.1%', true, AppColors.primary),
                _buildRevenueCard(context, 'This Year', 'R892,400', '+18.5%', true, AppColors.secondary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Target',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '85% of monthly target achieved',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '85%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(BuildContext context, String title, String amount, 
      String change, bool isPositive, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}