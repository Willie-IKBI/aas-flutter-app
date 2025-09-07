import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../parts/presentation/pages/parts_management_page.dart';
import '../../../admin/presentation/pages/user_management_page.dart';
import '../../../orders/presentation/pages/create_order_wizard.dart';
import '../../../orders/presentation/pages/active_jobs_page.dart';
import '../../../orders/presentation/widgets/pipeline_board.dart';
import '../../../orders/presentation/providers/pipeline_provider.dart';

class OperationsDashboard extends ConsumerStatefulWidget {
  const OperationsDashboard({super.key});

  @override
  ConsumerState<OperationsDashboard> createState() =>
      _OperationsDashboardState();
}

class _OperationsDashboardState extends ConsumerState<OperationsDashboard>
    with TickerProviderStateMixin {
  List<UserProfile> _unassignedUsers = [];
  bool _isLoadingUsers = true;

  // Order statistics
  int _activeOrdersCount = 0;
  int _pendingApprovalCount = 0;
  int _completedTodayCount = 0;
  bool _isLoadingOrders = true;

  // Tab controller for dashboard views
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUnassignedUsers();
    _loadOrderStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUnassignedUsers() async {
    try {
      final users = await AuthService.getUnassignedUsers();
      setState(() {
        _unassignedUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _loadOrderStatistics() async {
    try {
      final activeCount = await OrderService.getActiveOrdersCount();
      final pendingCount = await OrderService.getPendingApprovalCount();
      final completedCount = await OrderService.getCompletedTodayCount();

      setState(() {
        _activeOrdersCount = activeCount;
        _pendingApprovalCount = pendingCount;
        _completedTodayCount = completedCount;
        _isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPipelineTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.onBackground.withValues(alpha: 0.7),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.view_kanban_outlined, size: 20),
            text: 'Pipeline',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildJobStatusOverview(),
          const SizedBox(height: 24),
          _buildEquipmentStatus(),
          const SizedBox(height: 24),
          _buildTodaySchedule(),
          const SizedBox(height: 24),
          _buildUrgentAlerts(),
        ],
      ),
    );
  }

  Widget _buildPipelineTab() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Job Pipeline',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final viewMode = ref.watch(viewModeProvider);
                            return IconButton(
                              onPressed: () {
                                ref
                                    .read(pipelineProvider.notifier)
                                    .setViewMode(PipelineViewMode.grid);
                              },
                              icon: const Icon(Icons.grid_view, size: 18),
                              tooltip: 'Grid View (2x4)',
                              style: IconButton.styleFrom(
                                backgroundColor: viewMode ==
                                        PipelineViewMode.grid
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                foregroundColor:
                                    viewMode == PipelineViewMode.grid
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final viewMode = ref.watch(viewModeProvider);
                            return IconButton(
                              onPressed: () {
                                ref
                                    .read(pipelineProvider.notifier)
                                    .setViewMode(PipelineViewMode.horizontal);
                              },
                              icon: const Icon(Icons.view_kanban, size: 18),
                              tooltip: 'Horizontal View (Desktop)',
                              style: IconButton.styleFrom(
                                backgroundColor: viewMode ==
                                        PipelineViewMode.horizontal
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                foregroundColor:
                                    viewMode == PipelineViewMode.horizontal
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final viewMode = ref.watch(viewModeProvider);
                            return IconButton(
                              onPressed: () {
                                ref
                                    .read(pipelineProvider.notifier)
                                    .setViewMode(PipelineViewMode.mobile);
                              },
                              icon: const Icon(Icons.phone_android, size: 18),
                              tooltip: 'Mobile View (Single Column)',
                              style: IconButton.styleFrom(
                                backgroundColor: viewMode ==
                                        PipelineViewMode.mobile
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                foregroundColor:
                                    viewMode == PipelineViewMode.mobile
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(pipelineProvider.notifier).refresh();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: const PipelineBoard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.infoGradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.engineering,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations Hub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Job management and equipment operations',
                  style: TextStyle(
                    fontSize: 16,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              _buildActionButton(
                title: 'User Management',
                icon: Icons.people,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementPage(),
                    ),
                  ).then(
                      (_) => _loadUnassignedUsers()); // Refresh after returning
                },
                badge: _unassignedUsers.isNotEmpty
                    ? _unassignedUsers.length.toString()
                    : null,
              ),
              _buildActionButton(
                title: 'Create Order',
                icon: Icons.add_circle_outline,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOrderWizard(),
                    ),
                  ).then(
                      (_) => _loadOrderStatistics()); // Refresh after returning
                },
              ),
              _buildActionButton(
                title: 'Assign Technician',
                icon: Icons.person_add_outlined,
                color: AppColors.secondary,
                onTap: () {},
              ),
              _buildActionButton(
                title: 'Schedule Job',
                icon: Icons.schedule,
                color: AppColors.info,
                onTap: () {},
              ),
              _buildActionButton(
                title: 'Update Status',
                icon: Icons.update,
                color: AppColors.warning,
                onTap: () {},
              ),
              _buildActionButton(
                title: 'Manage Parts',
                icon: Icons.inventory_2,
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PartsManagementPage(),
                    ),
                  );
                },
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
    String? badge,
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
        child: Stack(
          children: [
            Column(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobStatusOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Status Overview',
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
                child: _buildStatusCard(
                  title: 'Active Jobs',
                  count:
                      _isLoadingOrders ? '...' : _activeOrdersCount.toString(),
                  color: AppColors.info,
                  icon: Icons.engineering,
                  isLoading: _isLoadingOrders,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActiveJobsPage(),
                      ),
                    ).then((_) =>
                        _loadOrderStatistics()); // Refresh after returning
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard(
                  title: 'Pending Approval',
                  count: _isLoadingOrders
                      ? '...'
                      : _pendingApprovalCount.toString(),
                  color: AppColors.warning,
                  icon: Icons.pending,
                  isLoading: _isLoadingOrders,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard(
                  title: 'Completed Today',
                  count: _isLoadingOrders
                      ? '...'
                      : _completedTodayCount.toString(),
                  color: AppColors.success,
                  icon: Icons.check_circle,
                  isLoading: _isLoadingOrders,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final Widget cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          if (isLoading)
            SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildEquipmentStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equipment Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildEquipmentItem(
            name: 'Excavator #001',
            status: 'In Use',
            location: 'Site A',
            color: AppColors.info,
          ),
          _buildEquipmentItem(
            name: 'Bulldozer #002',
            status: 'Maintenance',
            location: 'Workshop',
            color: AppColors.warning,
          ),
          _buildEquipmentItem(
            name: 'Crane #003',
            status: 'Available',
            location: 'Site B',
            color: AppColors.success,
          ),
          _buildEquipmentItem(
            name: 'Loader #004',
            status: 'Repair',
            location: 'Service Center',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentItem({
    required String name,
    required String status,
    required String location,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.construction,
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
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildScheduleItem(
            time: '09:00',
            title: 'Equipment Inspection',
            description: 'Routine maintenance check',
            color: AppColors.info,
          ),
          _buildScheduleItem(
            time: '11:30',
            title: 'Client Meeting',
            description: 'Project review with ABC Construction',
            color: AppColors.primary,
          ),
          _buildScheduleItem(
            time: '14:00',
            title: 'Parts Delivery',
            description: 'New hydraulic parts arrival',
            color: AppColors.success,
          ),
          _buildScheduleItem(
            time: '16:30',
            title: 'Team Briefing',
            description: 'Daily operations update',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildUrgentAlerts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Urgent Alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildAlertItem(
            title: 'Equipment Breakdown',
            description: 'Crane #003 requires immediate attention',
            priority: 'High',
            color: AppColors.error,
          ),
          _buildAlertItem(
            title: 'Low Stock Alert',
            description: 'Hydraulic fluid running low',
            priority: 'Medium',
            color: AppColors.warning,
          ),
          _buildAlertItem(
            title: 'Safety Inspection Due',
            description: 'Excavator #001 safety check overdue',
            priority: 'Medium',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String title,
    required String description,
    required String priority,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priority,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
