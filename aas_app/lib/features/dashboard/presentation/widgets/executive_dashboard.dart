import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../../../clients/presentation/pages/client_management_page.dart';

class ExecutiveDashboard extends StatefulWidget {
  const ExecutiveDashboard({super.key});

  @override
  State<ExecutiveDashboard> createState() => _ExecutiveDashboardState();
}

class _ExecutiveDashboardState extends State<ExecutiveDashboard> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 16.0 : isTablet ? 20.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(isDesktop, isTablet),
              SizedBox(height: isDesktop ? 16 : isTablet ? 20 : 24),
              _buildKeyMetrics(isDesktop, isTablet),
              SizedBox(height: isDesktop ? 16 : isTablet ? 20 : 24),
              _buildQuickActions(isDesktop, isTablet),
              SizedBox(height: isDesktop ? 16 : isTablet ? 20 : 24),
              _buildRecentActivity(isDesktop, isTablet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(bool isDesktop, bool isTablet) {
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(isDesktop ? 10 : isTablet ? 12 : 15),
            ),
            child: Icon(
              Icons.trending_up,
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
                  'Executive Overview',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : isTablet ? 22 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                SizedBox(height: isDesktop ? 2 : isTablet ? 3 : 4),
                Text(
                  'Key business metrics and performance insights',
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

  Widget _buildKeyMetrics(bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : isTablet ? 3 : 2,
      crossAxisSpacing: isDesktop ? 12 : isTablet ? 14 : 16,
      mainAxisSpacing: isDesktop ? 12 : isTablet ? 14 : 16,
      childAspectRatio: isDesktop ? 1.8 : isTablet ? 1.6 : 1.5,
      children: [
        _buildMetricCard(
          title: 'Monthly Revenue',
          value: 'R124,500',
          change: '+12.5%',
          isPositive: true,
          icon: Icons.attach_money,
          color: AppColors.success,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
        _buildMetricCard(
          title: 'Active Jobs',
          value: '47',
          change: '+3',
          isPositive: true,
          icon: Icons.engineering,
          color: AppColors.info,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
        _buildMetricCard(
          title: 'Equipment Utilization',
          value: '78%',
          change: '-2.1%',
          isPositive: false,
          icon: Icons.construction,
          color: AppColors.warning,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
        _buildMetricCard(
          title: 'Customer Satisfaction',
          value: '4.8/5',
          change: '+0.2',
          isPositive: true,
          icon: Icons.star,
          color: AppColors.secondary,
          isDesktop: isDesktop,
          isTablet: isTablet,
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
    required bool isDesktop,
    required bool isTablet,
  }) {
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
              fontSize: isDesktop ? 24 : isTablet ? 26 : 28,
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

  Widget _buildQuickActions(bool isDesktop, bool isTablet) {
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
                title: 'View Reports',
                icon: Icons.analytics_outlined,
                color: AppColors.info,
                onTap: () {},
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              _buildActionButton(
                title: 'Equipment Status',
                icon: Icons.construction,
                color: AppColors.warning,
                onTap: () {},
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              _buildActionButton(
                title: 'Client Analytics',
                icon: Icons.analytics,
                color: AppColors.primary,
                onTap: () {},
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              _buildActionButton(
                title: 'Financial Overview',
                icon: Icons.account_balance_wallet,
                color: AppColors.success,
                onTap: () {},
                isDesktop: isDesktop,
                isTablet: isTablet,
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
    required bool isDesktop,
    required bool isTablet,
  }) {
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

  Widget _buildRecentActivity(bool isDesktop, bool isTablet) {
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
            'Recent Activity',
            style: TextStyle(
              fontSize: isDesktop ? 18 : isTablet ? 19 : 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : isTablet ? 18 : 20),
          _buildActivityItem(
            title: 'New order #1234 created',
            subtitle: 'Excavator repair for ABC Construction',
            time: '2 hours ago',
            icon: Icons.add_circle,
            color: AppColors.success,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
          _buildActivityItem(
            title: 'Job #567 completed',
            subtitle: 'Bulldozer maintenance completed',
            time: '4 hours ago',
            icon: Icons.check_circle,
            color: AppColors.success,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
          _buildActivityItem(
            title: 'Equipment breakdown reported',
            subtitle: 'Crane #789 needs urgent repair',
            time: '6 hours ago',
            icon: Icons.warning,
            color: AppColors.warning,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
          _buildActivityItem(
            title: 'New customer registered',
            subtitle: 'XYZ Mining Company',
            time: '1 day ago',
            icon: Icons.person_add,
            color: AppColors.info,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isDesktop ? 12 : isTablet ? 14 : 16),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 32 : isTablet ? 36 : 40,
            height: isDesktop ? 32 : isTablet ? 36 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 8 : isTablet ? 9 : 10),
            ),
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 16 : isTablet ? 18 : 20,
            ),
          ),
          SizedBox(width: isDesktop ? 12 : isTablet ? 14 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : isTablet ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                SizedBox(height: isDesktop ? 1 : isTablet ? 1.5 : 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isDesktop ? 10 : isTablet ? 11 : 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: isDesktop ? 10 : isTablet ? 11 : 12,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
