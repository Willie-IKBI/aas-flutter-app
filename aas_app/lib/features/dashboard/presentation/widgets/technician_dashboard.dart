import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/models/order.dart';
import '../providers/dashboard_providers.dart';

class TechnicianDashboard extends ConsumerWidget {
  const TechnicianDashboard({super.key});

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
              _buildKeyMetricsBar(context, activeOrdersAsync, isDesktop, isTablet, isMobile),
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
          'Technician Workspace',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage tasks, equipment, and daily operations',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsBar(BuildContext context, AsyncValue<List<Order>> activeOrdersAsync, 
      bool isDesktop, bool isTablet, bool isMobile) {
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
                  Expanded(child: _buildCompactMetricCard(context, 'My Tasks', '3', Icons.assignment, AppColors.primary)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'In Progress', '1', Icons.build, AppColors.warning)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCompactMetricCard(context, 'Completed Today', '2', Icons.check_circle, AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCompactMetricCard(context, 'Equipment', '5', Icons.inventory, AppColors.info)),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'My Tasks',
                  '3',
                  Icons.assignment,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'In Progress',
                  '1',
                  Icons.build,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Completed Today',
                  '2',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactMetricCard(
                  context,
                  'Equipment',
                  '5',
                  Icons.inventory,
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

  Widget _buildMainContent(BuildContext context, AsyncValue<List<Order>> activeOrdersAsync, 
      bool isDesktop, bool isTablet, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            height: 350, // Fixed height for mobile tasks
            child: _buildMyTasksWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // Fixed height for mobile equipment access
            child: _buildEquipmentAccessWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Fixed height for mobile schedule
            child: _buildTodayScheduleWidget(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // Fixed height for mobile communication
            child: _buildCommunicationWidget(context),
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
        _buildMyTasksWidget(context),
        _buildEquipmentAccessWidget(context),
        _buildTodayScheduleWidget(context),
        _buildCommunicationWidget(context),
      ],
    );
  }

  Widget _buildMyTasksWidget(BuildContext context) {
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
                'My Tasks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all tasks
                },
                child: Text('View All', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildTaskItem(
                  context,
                  'Excavator #001 Repair',
                  'ABC Construction',
                  'Site A - Workshop',
                  'High',
                  'In Progress',
                  '2 hours remaining',
                  AppColors.warning,
                ),
                _buildTaskItem(
                  context,
                  'Bulldozer #003 Maintenance',
                  'XYZ Mining',
                  'Site B - Field',
                  'Normal',
                  'Scheduled',
                  'Tomorrow 09:00',
                  AppColors.info,
                ),
                _buildTaskItem(
                  context,
                  'Crane #007 Inspection',
                  'DEF Contractors',
                  'Site C - Workshop',
                  'Low',
                  'Pending',
                  'Next week',
                  AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, String title, String customer, 
      String location, String priority, String status, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                customer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentAccessWidget(BuildContext context) {
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
              Icon(Icons.inventory, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Equipment Access',
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
              childAspectRatio: 1.5,
              children: [
                _buildEquipmentCard(
                  context,
                  'Check In/Out',
                  'Equipment access control',
                  Icons.login,
                  AppColors.primary,
                ),
                _buildEquipmentCard(
                  context,
                  'Maintenance Records',
                  'View service history',
                  Icons.history,
                  AppColors.info,
                ),
                _buildEquipmentCard(
                  context,
                  'Parts Inventory',
                  'Check available parts',
                  Icons.inventory_2,
                  AppColors.secondary,
                ),
                _buildEquipmentCard(
                  context,
                  'Safety Checks',
                  'Equipment safety protocols',
                  Icons.security,
                  AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, String title, String subtitle, 
      IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to equipment function
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayScheduleWidget(BuildContext context) {
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
              Icon(Icons.schedule, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "Today's Schedule",
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
                _buildScheduleItem(context, '08:00', 'Start Shift', 'Equipment check and briefing', true),
                _buildScheduleItem(context, '09:00', 'Excavator #001 Repair', 'ABC Construction - Workshop A', false),
                _buildScheduleItem(context, '12:00', 'Lunch Break', '30 minutes', false),
                _buildScheduleItem(context, '13:00', 'Bulldozer #003 Maintenance', 'XYZ Mining - Site B', false),
                _buildScheduleItem(context, '17:00', 'End Shift', 'Equipment handover and reports', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, String time, String title, 
      String subtitle, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
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
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                      ),
                    ),
                    if (isCompleted)
                      Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationWidget(BuildContext context) {
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
              Icon(Icons.chat, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Communication',
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
              childAspectRatio: 1.5,
              children: [
                _buildCommButton(context, 'Team Chat', '3 new messages', Icons.chat, AppColors.info),
                _buildCommButton(context, 'Customer Updates', '2 pending', Icons.message, AppColors.primary),
                _buildCommButton(context, 'Emergency Contact', '24/7 support', Icons.emergency, AppColors.error),
                _buildCommButton(context, 'Reports', 'Submit daily report', Icons.assignment, AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommButton(BuildContext context, String title, String subtitle, 
      IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to communication function
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}