import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../widgets/client_list.dart';
import '../widgets/client_search.dart';
import '../widgets/client_stats.dart';
import '../widgets/add_client_fab.dart';

class ClientManagementPage extends StatefulWidget {
  const ClientManagementPage({super.key});

  @override
  State<ClientManagementPage> createState() => _ClientManagementPageState();
}

class _ClientManagementPageState extends State<ClientManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: _buildTabBarView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const AddClientFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Manage your clients and their equipment',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show client management settings
            },
            icon: const Icon(
              Icons.settings,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClientSearch(
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(24.0),
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
            icon: Icon(Icons.people_outline),
            text: 'All Clients',
          ),
          Tab(
            icon: Icon(Icons.star_outline),
            text: 'Active',
          ),
          Tab(
            icon: Icon(Icons.analytics_outlined),
            text: 'Analytics',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        ClientList(
          filter: 'all',
          searchQuery: _searchQuery,
        ),
        ClientList(
          filter: 'active',
          searchQuery: _searchQuery,
        ),
        const ClientStats(),
      ],
    );
  }
}
