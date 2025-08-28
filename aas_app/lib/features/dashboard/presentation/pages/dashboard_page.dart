import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/config/supabase_config.dart';
import '../widgets/executive_dashboard.dart';
import '../widgets/operations_dashboard.dart';
import '../widgets/technician_dashboard.dart';
import '../widgets/sales_dashboard.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final int initialTab;
  final bool showUserManagement;
  
  const DashboardPage({
    super.key,
    this.initialTab = 0,
    this.showUserManagement = false,
  });

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _buildTabBarView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Logo and company name
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.construction,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AAS Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Equipment Repair Management',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // User profile and sign out
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outline.withOpacity(0.2),
                ),
              ),
              child: Icon(
                Icons.person_outline,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
            onSelected: (value) {
              if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Profile', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Settings', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text('Sign Out', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
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
            icon: Icon(Icons.analytics_outlined),
            text: 'Executive',
          ),
          Tab(
            icon: Icon(Icons.engineering_outlined),
            text: 'Operations',
          ),
          Tab(
            icon: Icon(Icons.build_outlined),
            text: 'Technician',
          ),
          Tab(
            icon: Icon(Icons.people_outline),
            text: 'Sales',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: const [
        ExecutiveDashboard(),
        OperationsDashboard(),
        TechnicianDashboard(),
        SalesDashboard(),
      ],
    );
  }

  Future<void> _signOut() async {
    try {
              await SupabaseConfig.auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed out successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
