import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../../../clients/presentation/pages/client_management_page.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
                     _buildSalesMetrics(),
           const SizedBox(height: 24),
           _buildQuickActions(),
           const SizedBox(height: 24),
           _buildOrderPipeline(),
          const SizedBox(height: 24),
          _buildCustomerManagement(),
          const SizedBox(height: 24),
          _buildRevenueTracking(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1200;
    final bool isTablet = width >= 768 && width < 1200;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 20 : 24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : isTablet ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: isDesktop ? 8 : isTablet ? 12 : 15,
            offset: Offset(0, isDesktop ? 4 : isTablet ? 6 : 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 48 : isTablet ? 54 : 60,
            height: isDesktop ? 48 : isTablet ? 54 : 60,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(isDesktop ? 10 : isTablet ? 12 : 15),
            ),
            child: Icon(
              Icons.people,
              color: Colors.white,
              size: isDesktop ? 24 : isTablet ? 26 : 30,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : isTablet ? 18 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales & Customer Hub',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : isTablet ? 22 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                SizedBox(height: isDesktop ? 2 : isTablet ? 3 : 4),
                Text(
                  'Customer management and sales pipeline',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : isTablet ? 15 : 16,
                    color: AppColors.onSurfaceVariant,
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
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1200;
    final bool isTablet = width >= 768 && width < 1200;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 20 : 24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : isTablet ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: isDesktop ? 8 : isTablet ? 12 : 15,
            offset: Offset(0, isDesktop ? 4 : isTablet ? 6 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isDesktop ? 18 : isTablet ? 19 : 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : isTablet ? 18 : 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : isTablet ? 3 : 2,
            crossAxisSpacing: isDesktop ? 12 : isTablet ? 14 : 16,
            mainAxisSpacing: isDesktop ? 12 : isTablet ? 14 : 16,
            childAspectRatio: isDesktop ? 3.0 : isTablet ? 2.8 : 2.5,
            children: [
              _buildActionButton(
                title: 'Manage Clients',
                icon: Icons.people_outline,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientManagementPage(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                title: 'Create Quote',
                icon: Icons.description,
                color: AppColors.info,
                onTap: () {},
              ),
              _buildActionButton(
                title: 'Follow Up',
                icon: Icons.phone,
                color: AppColors.secondary,
                onTap: () {},
              ),
              _buildActionButton(
                title: 'Schedule Meeting',
                icon: Icons.calendar_today,
                color: AppColors.success,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1200;
    final bool isTablet = width >= 768 && width < 1200;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isDesktop ? 8 : isTablet ? 10 : 12),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 12 : isTablet ? 14 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isDesktop ? 8 : isTablet ? 10 : 12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: isDesktop ? 20 : isTablet ? 22 : 24,
            ),
            SizedBox(width: isDesktop ? 8 : isTablet ? 10 : 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : isTablet ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesMetrics() {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1200;
    final bool isTablet = width >= 768 && width < 1200;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : isTablet ? 3 : 2,
      crossAxisSpacing: isDesktop ? 12 : isTablet ? 14 : 16,
      mainAxisSpacing: isDesktop ? 12 : isTablet ? 14 : 16,
      childAspectRatio: isDesktop ? 1.8 : isTablet ? 1.5 : 1.3,
      children: [
        _buildMetricCard(
          title: 'Monthly Sales',
          value: 'R89,500',
          change: '+15.2%',
          isPositive: true,
          icon: Icons.trending_up,
          color: AppColors.success,
        ),
        _buildMetricCard(
          title: 'New Customers',
          value: '12',
          change: '+3',
          isPositive: true,
          icon: Icons.person_add,
          color: AppColors.info,
        ),
        _buildMetricCard(
          title: 'Conversion Rate',
          value: '68%',
          change: '+5.1%',
          isPositive: true,
          icon: Icons.analytics,
          color: AppColors.primary,
        ),
        _buildMetricCard(
          title: 'Average Deal Size',
          value: 'R7,450',
          change: '+12.3%',
          isPositive: true,
          icon: Icons.attach_money,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1200;
    final bool isTablet = width >= 768 && width < 1200;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 18 : 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : isTablet ? 14 : 16),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: isDesktop ? 6 : isTablet ? 8 : 10,
            offset: Offset(0, isDesktop ? 3 : isTablet ? 4 : 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 6 : isTablet ? 7 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 6 : isTablet ? 7 : 8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isDesktop ? 18 : isTablet ? 19 : 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 6 : isTablet ? 7 : 8,
                  vertical: isDesktop ? 3 : isTablet ? 3.5 : 4,
                ),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : isTablet ? 10 : 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: isDesktop ? 10 : isTablet ? 11 : 12,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    SizedBox(width: isDesktop ? 3 : isTablet ? 3.5 : 4),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: isDesktop ? 10 : isTablet ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 12 : isTablet ? 14 : 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 22 : isTablet ? 23 : 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: isDesktop ? 2 : isTablet ? 3 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 12 : isTablet ? 13 : 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPipeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Pipeline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildPipelineItem(
            stage: 'New Quotes',
            count: '8',
            value: 'R45,200',
            color: AppColors.info,
            icon: Icons.description,
          ),
          _buildPipelineItem(
            stage: 'Pending Approval',
            count: '5',
            value: 'R32,800',
            color: AppColors.warning,
            icon: Icons.pending,
          ),
          _buildPipelineItem(
            stage: 'Negotiation',
            count: '3',
            value: 'R28,500',
            color: AppColors.secondary,
            icon: Icons.handshake,
          ),
          _buildPipelineItem(
            stage: 'Ready to Close',
            count: '2',
            value: 'R18,900',
            color: AppColors.success,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem({
    required String stage,
    required String count,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count orders • $value',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerManagement() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientManagementPage(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCustomerItem(
            name: 'ABC Construction',
            status: 'Active',
            lastOrder: '2 days ago',
            totalSpent: 'R12,450',
            priority: 'High',
            color: AppColors.success,
          ),
          _buildCustomerItem(
            name: 'XYZ Mining',
            status: 'Active',
            lastOrder: '1 week ago',
            totalSpent: 'R8,900',
            priority: 'Medium',
            color: AppColors.info,
          ),
          _buildCustomerItem(
            name: 'DEF Contractors',
            status: 'Inactive',
            lastOrder: '3 weeks ago',
            totalSpent: 'R5,200',
            priority: 'Low',
            color: AppColors.warning,
          ),
          _buildCustomerItem(
            name: 'GHI Industries',
            status: 'Prospect',
            lastOrder: 'Never',
            totalSpent: 'R0',
            priority: 'High',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerItem({
    required String name,
    required String status,
    required String lastOrder,
    required String totalSpent,
    required String priority,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$status • Last order: $lastOrder',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total spent: $totalSpent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTracking() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                  title: 'This Month',
                  amount: 'R89,500',
                  change: '+15.2%',
                  isPositive: true,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueCard(
                  title: 'Last Month',
                  amount: 'R77,800',
                  change: '+8.7%',
                  isPositive: true,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                  title: 'This Quarter',
                  amount: 'R245,200',
                  change: '+12.1%',
                  isPositive: true,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueCard(
                  title: 'This Year',
                  amount: 'R892,400',
                  change: '+18.5%',
                  isPositive: true,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Target',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '85% of monthly target achieved',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '85%',
                  style: TextStyle(
                    fontSize: 18,
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

  Widget _buildRevenueCard({
    required String title,
    required String amount,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
