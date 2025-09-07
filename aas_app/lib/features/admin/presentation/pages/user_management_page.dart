import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/user_management_provider.dart';
import '../providers/search_controller_provider.dart';
import '../widgets/user_card_skeleton.dart';
import '../widgets/pagination_widget.dart';
import '../widgets/inline_editable_text.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    // Load users when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userManagementProvider.notifier).loadUsers();
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _assignRole(UserProfile user) async {
    final selectedRole = await showDialog<UserRole>(
      context: context,
      builder: (context) => _RoleAssignmentDialog(user: user),
    );

    if (selectedRole != null) {
      await ref
          .read(userManagementProvider.notifier)
          .assignRole(user, selectedRole);

      final state = ref.read(userManagementProvider);
      if (state.hasError) {
        _showErrorSnackBar(state.error!);
      } else {
        _showSuccessSnackBar(
            'Role assigned successfully to ${user.displayName}');
      }
    }
  }

  Future<void> _bulkAssignRole() async {
    final state = ref.read(userManagementProvider);
    if (state.selectedUserIds.isEmpty) return;

    final selectedRole = await showDialog<UserRole>(
      context: context,
      builder: (context) => _BulkRoleAssignmentDialog(
        selectedCount: state.selectedUserIds.length,
      ),
    );

    if (selectedRole != null) {
      await ref
          .read(userManagementProvider.notifier)
          .bulkAssignRole(selectedRole);

      final newState = ref.read(userManagementProvider);
      if (newState.hasError) {
        _showErrorSnackBar(newState.error!);
      }
    }
  }

  void _exportUsers() {
    final state = ref.read(userManagementProvider);
    final usersToExport =
        state.isMultiSelectMode && state.selectedUserIds.isNotEmpty
            ? state.filteredUsers
                .where((user) => state.selectedUserIds.contains(user.id))
                .toList()
            : state.filteredUsers;

    // Simple CSV export functionality
    final csvData = usersToExport.map((user) {
      return [
        user.displayName ?? '',
        user.email ?? '',
        user.role.toDisplayString(),
        user.status,
        user.createdAt.toIso8601String(),
        user.department ?? '',
        user.location ?? '',
      ].join(',');
    }).join('\n');

    const csvHeader = 'Name,Email,Role,Status,Created,Department,Location\n';
    final csvContent = csvHeader + csvData;

    // In a real app, you'd use a file picker or download service
    print('CSV Export:\n$csvContent');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${usersToExport.length} users exported to console (implement file download)'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateDisplayName(
      UserProfile user, String newDisplayName) async {
    await ref
        .read(userManagementProvider.notifier)
        .updateUserDisplayName(user.id, newDisplayName);

    final state = ref.read(userManagementProvider);
    if (state.hasError) {
      _showErrorSnackBar(state.error!);
    } else {
      _showSuccessSnackBar(
          'Display name updated successfully for ${user.email}');
    }
  }

  Future<void> _deleteUser(UserProfile user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.displayName ?? user.email}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // TODO: Implement user deletion in AuthService and UserManagementNotifier
      _showErrorSnackBar('User deletion not yet implemented');
    }
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name cannot be empty';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Display name must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'Display name must be less than 50 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userManagementProvider);
    final searchController = ref.watch(searchControllerProvider);

    // Show error snackbar if there's an error
    ref.listen(userManagementProvider, (previous, next) {
      if (next.hasError && previous?.error != next.error) {
        _showErrorSnackBar(next.error!);
        ref.read(userManagementProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.isMultiSelectMode
            ? '${state.selectedCount} selected'
            : 'User Management'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        actions: state.isMultiSelectMode
            ? [
                if (state.selectedUserIds.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    onPressed: _bulkAssignRole,
                    tooltip: 'Bulk assign role',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _exportUsers,
                    tooltip: 'Export selected',
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref
                      .read(userManagementProvider.notifier)
                      .toggleMultiSelectMode(),
                  tooltip: 'Exit multi-select',
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => ref
                      .read(userManagementProvider.notifier)
                      .toggleMultiSelectMode(),
                  tooltip: 'Multi-select mode',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _exportUsers,
                  tooltip: 'Export all',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ref.read(userManagementProvider.notifier).loadUsers(),
                  tooltip: 'Refresh',
                ),
              ],
      ),
      body: state.isLoading
          ? const UserListSkeleton(itemCount: 8)
          : Column(
              children: [
                // Alert for unassigned users
                if (state.hasUnassignedUsers) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${state.unassignedUsers.length} user(s) awaiting role assignment',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(userManagementProvider.notifier)
                                .setSelectedFilter('unassigned');
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Search Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users by name, email, or role...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.outline.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.outline.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Filter Tabs and Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildFilterChip(
                              'All Users', 'all', state.selectedFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pending Approval', 'unassigned',
                              state.selectedFilter),
                          const Spacer(),
                          if (state.isMultiSelectMode &&
                              state.filteredUsers.isNotEmpty) ...[
                            TextButton(
                              onPressed: state.isAllSelected
                                  ? () => ref
                                      .read(userManagementProvider.notifier)
                                      .clearSelection()
                                  : () => ref
                                      .read(userManagementProvider.notifier)
                                      .selectAllUsers(),
                              child: Text(
                                state.isAllSelected
                                    ? 'Clear All'
                                    : 'Select All',
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Sorting and Pagination Controls
                      Row(
                        children: [
                          const Text('Sort by:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: state.sortBy,
                            onChanged: (value) {
                              ref
                                  .read(userManagementProvider.notifier)
                                  .setSortBy(value!);
                            },
                            items: const [
                              DropdownMenuItem(
                                  value: 'name', child: Text('Name')),
                              DropdownMenuItem(
                                  value: 'email', child: Text('Email')),
                              DropdownMenuItem(
                                  value: 'role', child: Text('Role')),
                              DropdownMenuItem(
                                  value: 'created', child: Text('Created')),
                              DropdownMenuItem(
                                  value: 'status', child: Text('Status')),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(state.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward),
                            onPressed: () {
                              ref
                                  .read(userManagementProvider.notifier)
                                  .toggleSortDirection();
                            },
                            tooltip: state.sortAscending
                                ? 'Sort descending'
                                : 'Sort ascending',
                          ),
                          const Spacer(),
                          const Text('Show:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: state.itemsPerPage,
                            onChanged: (value) {
                              ref
                                  .read(userManagementProvider.notifier)
                                  .setItemsPerPage(value!);
                            },
                            items: const [
                              DropdownMenuItem(value: 5, child: Text('5')),
                              DropdownMenuItem(value: 10, child: Text('10')),
                              DropdownMenuItem(value: 20, child: Text('20')),
                              DropdownMenuItem(value: 50, child: Text('50')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Statistics
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard(
                          'Total Users', state.users.length.toString()),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          'Pending', state.unassignedUsers.length.toString()),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Users List
                Expanded(
                  child: state.paginatedUsers.isEmpty
                      ? _buildEmptyState(state)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.paginatedUsers.length,
                          itemBuilder: (context, index) {
                            final user = state.paginatedUsers[index];
                            return _buildUserCard(user, state);
                          },
                        ),
                ),

                // Pagination Widget
                if (state.totalPages > 1)
                  PaginationWidget(
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    totalItems: state.totalFilteredUsers,
                    itemsPerPage: state.itemsPerPage,
                    onPrevious: () => ref
                        .read(userManagementProvider.notifier)
                        .goToPreviousPage(),
                    onNext: () => ref
                        .read(userManagementProvider.notifier)
                        .goToNextPage(),
                    onPageChanged: (page) => ref
                        .read(userManagementProvider.notifier)
                        .setCurrentPage(page),
                  ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(userManagementProvider.notifier).setSelectedFilter(value);
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onBackground.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserProfile user, UserManagementState state) {
    final isSelected = state.selectedUserIds.contains(user.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.surface,
      elevation: isSelected ? 4 : 1,
      child: Semantics(
        label:
            'User: ${user.displayName ?? user.email}, Role: ${user.role.toDisplayString()}',
        button: true,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: state.isMultiSelectMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) => ref
                      .read(userManagementProvider.notifier)
                      .toggleUserSelection(user.id),
                )
              : CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          title: InlineEditableText(
            key: ValueKey('display_name_${user.id}_${user.displayName}'),
            initialValue: user.displayName ?? '',
            hintText: 'Enter display name',
            onSave: (newName) => _updateDisplayName(user, newName),
            validator: _validateDisplayName,
            enabled: !state.isMultiSelectMode && !state.isAssigningRole,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                user.email ?? 'No Email',
                style: TextStyle(
                  color: AppColors.onBackground.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Role Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleBackgroundColor(user.role),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getRoleColor(user.role).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.role.toDisplayString(),
                          style: TextStyle(
                            color: _getRoleColor(user.role),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: user.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user.isActive
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      user.status.toUpperCase(),
                      style: TextStyle(
                        color: user.isActive
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Additional Info
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.onBackground.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Joined ${_formatDate(user.createdAt)}',
                    style: TextStyle(
                      color: AppColors.onBackground.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  if (user.department != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.business,
                      size: 12,
                      color: AppColors.onBackground.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.department!,
                      style: TextStyle(
                        color: AppColors.onBackground.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: state.isMultiSelectMode
              ? null
              : user.isUnassigned
                  ? FilledButton(
                      onPressed: state.isAssigningRole
                          ? null
                          : () => _assignRole(user),
                      child: state.isAssigningRole
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Assign Role'),
                    )
                  : PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'role') {
                          _assignRole(user);
                        } else if (value == 'delete') {
                          _deleteUser(user);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'role',
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings, size: 18),
                              SizedBox(width: 8),
                              Text('Change Role'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete User',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(UserManagementState state) {
    String message;
    String subtitle;

    if (state.searchQuery.isNotEmpty) {
      message = 'No users found';
      subtitle = 'Try adjusting your search terms';
    } else if (state.selectedFilter == 'unassigned') {
      message = 'No pending users';
      subtitle = 'All users have been assigned roles';
    } else {
      message = 'No users found';
      subtitle = 'Users will appear here once they register';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.people_outline,
            size: 64,
            color: AppColors.onBackground.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onBackground.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withValues(alpha: 0.5),
                ),
          ),
          if (state.searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(searchControllerProvider).clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFDC2626); // Red-600
      case UserRole.manager:
        return const Color(0xFFEA580C); // Orange-600
      case UserRole.salesRep:
        return const Color(0xFF2563EB); // Blue-600
      case UserRole.technician:
        return const Color(0xFF059669); // Green-600
      case UserRole.unassigned:
        return const Color(0xFF6B7280); // Gray-500
    }
  }

  Color _getRoleBackgroundColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFFEF2F2); // Red-50
      case UserRole.manager:
        return const Color(0xFFFFF7ED); // Orange-50
      case UserRole.salesRep:
        return const Color(0xFFEFF6FF); // Blue-50
      case UserRole.technician:
        return const Color(0xFFF0FDF4); // Green-50
      case UserRole.unassigned:
        return const Color(0xFFF9FAFB); // Gray-50
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}

class _RoleAssignmentDialog extends StatefulWidget {
  const _RoleAssignmentDialog({required this.user});
  final UserProfile user;

  @override
  State<_RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<_RoleAssignmentDialog> {
  UserRole _selectedRole = UserRole.technician;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Role to ${widget.user.displayName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a role for this user:',
            style: TextStyle(
              color: AppColors.onBackground.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          ...UserRole.values
              .where((role) => role != UserRole.unassigned)
              .map((role) => RadioListTile<UserRole>(
                    title: Text(role.toDisplayString()),
                    subtitle: Text(_getRoleDescription(role)),
                    value: role,
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ))
              .toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedRole),
          child: const Text('Assign Role'),
        ),
      ],
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full system access and user management';
      case UserRole.manager:
        return 'Operations management and limited user access';
      case UserRole.salesRep:
        return 'Sales dashboard and customer management';
      case UserRole.technician:
        return 'Parts and order management';
      case UserRole.unassigned:
        return '';
    }
  }
}

class _BulkRoleAssignmentDialog extends StatefulWidget {
  const _BulkRoleAssignmentDialog({required this.selectedCount});
  final int selectedCount;

  @override
  State<_BulkRoleAssignmentDialog> createState() =>
      _BulkRoleAssignmentDialogState();
}

class _BulkRoleAssignmentDialogState extends State<_BulkRoleAssignmentDialog> {
  UserRole _selectedRole = UserRole.technician;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Role to ${widget.selectedCount} Users'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a role to assign to all selected users:',
            style: TextStyle(
              color: AppColors.onBackground.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          ...UserRole.values
              .where((role) => role != UserRole.unassigned)
              .map((role) => RadioListTile<UserRole>(
                    title: Text(role.toDisplayString()),
                    subtitle: Text(_getRoleDescription(role)),
                    value: role,
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ))
              .toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedRole),
          child: const Text('Assign Role'),
        ),
      ],
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full system access and user management';
      case UserRole.manager:
        return 'Operations management and limited user access';
      case UserRole.salesRep:
        return 'Sales dashboard and customer management';
      case UserRole.technician:
        return 'Parts and order management';
      case UserRole.unassigned:
        return '';
    }
  }
}
