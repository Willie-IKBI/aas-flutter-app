import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/order.dart';
import '../providers/dashboard_providers.dart';
import '../../../admin/presentation/pages/user_management_page.dart';
import '../../../orders/presentation/widgets/pipeline_board.dart';
import '../../../orders/presentation/providers/pipeline_provider.dart';
import '../../../orders/presentation/pages/create_order_wizard.dart';
import '../../../parts/presentation/widgets/parts_list.dart';
import '../../../parts/presentation/widgets/parts_search.dart';
import '../../../parts/presentation/widgets/parts_stats.dart';
import '../../../parts/presentation/widgets/add_part_fab.dart';
import '../../../parts/presentation/widgets/parts_grid.dart';
import '../../../parts/presentation/widgets/parts_detail_panel.dart';
import '../../../parts/presentation/widgets/parts_detail_modal.dart';
import '../../../parts/presentation/models/part.dart';
import '../../../../core/services/parts_service.dart';

class OperationsDashboard extends ConsumerStatefulWidget {
  const OperationsDashboard({super.key});

  @override
  ConsumerState<OperationsDashboard> createState() => _OperationsDashboardState();
}

class _OperationsDashboardState extends ConsumerState<OperationsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Part? _selectedPart;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unassignedUsersAsync = ref.watch(unassignedUsersProvider);
    final orderStatsAsync = ref.watch(orderStatisticsProvider);
    final activeOrdersAsync = ref.watch(activeOrdersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;

        return Column(
          children: [
            _buildHeader(context, isDesktop),
            const SizedBox(height: 16),
            
            // Tab Bar
            _buildTabBar(context),
            
            // Search bar for Parts tab
            if (_tabController.index == 2) // Parts tab
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: PartsSearch(
                  onSearchChanged: _onSearchChanged,
                ),
              ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Operations Overview Tab
                  _buildOperationsOverview(context, unassignedUsersAsync, orderStatsAsync, activeOrdersAsync, isDesktop, isTablet, isMobile),
                  
                  // Pipeline Tab
                  _buildPipelineTab(context),
                  
                  // Parts Tab
                  _buildPartsTab(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                  'Manage orders, users, parts, and operational workflows',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // New Job Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateOrderWizard(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('New Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard_outlined),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.account_tree_outlined),
            text: 'Pipeline',
          ),
          Tab(
            icon: Icon(Icons.inventory_2_outlined),
            text: 'Parts',
          ),
        ],
      ),
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
            height: 200, // Reduced height for mobile user management
            child: _buildCompactUserManagementWidget(context, unassignedUsersAsync),
          ),
        ],
      );
    }

    // Use Row layout instead of GridView to prevent overflow
    return SizedBox(
      height: 500, // Fixed height to prevent layout issues
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pipeline takes up more space
          Expanded(
            flex: isDesktop ? 3 : 2,
            child: _buildPipelineWidget(context),
          ),
          const SizedBox(width: 16),
          // User Management takes up less space
          Expanded(
            flex: isDesktop ? 1 : 1,
            child: _buildCompactUserManagementWidget(context, unassignedUsersAsync),
          ),
        ],
      ),
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
          SizedBox(
            height: 400, // Fixed height to prevent layout issues
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

  Widget _buildCompactUserManagementWidget(BuildContext context, AsyncValue<List<UserProfile>> unassignedUsersAsync) {
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
          // Compact status display
          unassignedUsersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All users assigned',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'No action required',
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
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${users.length} unassigned users',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Action required',
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
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error loading users',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
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

  // New tab content methods
  Widget _buildOperationsOverview(BuildContext context, AsyncValue<List<UserProfile>> unassignedUsersAsync, 
      AsyncValue<int> orderStatsAsync, AsyncValue<List<Order>> activeOrdersAsync, 
      bool isDesktop, bool isTablet, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : isTablet ? 20.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Bar
          _buildKeyMetricsBar(context, orderStatsAsync, activeOrdersAsync, isDesktop, isTablet, isMobile),
          const SizedBox(height: 24),

          // Main Content Grid
          _buildMainContent(context, unassignedUsersAsync, isDesktop, isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildPipelineTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: _buildPipelineWidget(context),
    );
  }

  Widget _buildPartsTab(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;

        if (isDesktop) {
          // Desktop: Master-Detail layout
          return Row(
            children: [
              // Master: Parts Grid
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Parts Stats - Compact height
                    Container(
                      height: 120, // Reduced height for more list space
                      padding: const EdgeInsets.all(16),
                      child: const PartsStats(),
                    ),
                    
                    // Parts Grid
                    Expanded(
                      child: PartsGrid(
                        searchQuery: _searchQuery,
                        filterActiveOnly: false,
                        selectedPartId: _selectedPart?.id,
                        onPartSelected: (part) {
                          setState(() {
                            _selectedPart = part;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Detail: Parts Detail Panel
              if (_selectedPart != null)
                Expanded(
                  flex: 1,
                  child: PartsDetailPanel(
                    part: _selectedPart!,
                    onEdit: () => _editPart(_selectedPart!),
                    onDelete: () => _deletePart(_selectedPart!),
                  ),
                ),
            ],
          );
        } else {
          // Mobile/Tablet: Full-screen with modal details
          return Scaffold(
            body: Column(
              children: [
                // Parts Stats - Compact height for mobile
                Container(
                  height: isMobile ? 100 : 120, // Much smaller height
                  padding: const EdgeInsets.all(16),
                  child: const PartsStats(),
                ),
                
                // Parts Grid
                Expanded(
                  child: PartsGrid(
                    searchQuery: _searchQuery,
                    filterActiveOnly: false,
                    onPartSelected: (part) => _showPartDetailModal(context, part),
                  ),
                ),
              ],
            ),
            floatingActionButton: const AddPartFAB(),
          );
        }
      },
    );
  }

  void _showPartDetailModal(BuildContext context, Part part) {
    showDialog(
      context: context,
      builder: (context) => PartsDetailModal(
        part: part,
        onEdit: () {
          Navigator.of(context).pop();
          _editPart(part);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _deletePart(part);
        },
      ),
    );
  }

  void _editPart(Part part) {
    // TODO: Navigate to edit part page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${part.partName}'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deletePart(Part part) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Part'),
        content: Text('Are you sure you want to delete "${part.partName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await PartsService.deletePart(part.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${part.partName} deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _selectedPart = null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete part: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}