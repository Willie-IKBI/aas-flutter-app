import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../widgets/parts_list.dart';
import '../widgets/parts_search.dart';
import '../widgets/parts_stats.dart';
import '../widgets/add_part_fab.dart';
import '../../../../core/services/parts_service.dart';

class PartsManagementPage extends StatefulWidget {
  const PartsManagementPage({super.key});

  @override
  State<PartsManagementPage> createState() => _PartsManagementPageState();
}

class _PartsManagementPageState extends State<PartsManagementPage>
    with SingleTickerProviderStateMixin {
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Parts Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All Parts'),
            Tab(text: 'Active Parts'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          if (_tabController.index != 2) // Don't show search on Analytics tab
            Container(
              padding: const EdgeInsets.all(16),
              child: PartsSearch(
                onSearchChanged: _onSearchChanged,
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Parts tab
                PartsList(
                  searchQuery: _searchQuery,
                  filterActiveOnly: false,
                ),

                // Active Parts tab
                PartsList(
                  searchQuery: _searchQuery,
                  filterActiveOnly: true,
                ),

                // Analytics tab
                const PartsStats(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index != 2 // Don't show FAB on Analytics tab
              ? const AddPartFAB()
              : null,
    );
  }
}
