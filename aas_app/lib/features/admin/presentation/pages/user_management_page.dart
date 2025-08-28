import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/theme/app_colors.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<UserProfile> _users = [];
  List<UserProfile> _unassignedUsers = [];
  bool _isLoading = true;
  bool _isAssigningRole = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    print('🔄 Starting _loadUsers...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('   📞 Calling AuthService.getAllUsers()...');
      final users = await AuthService.getAllUsers();
      print('   ✅ getAllUsers returned ${users.length} users');
      
      print('   📞 Calling AuthService.getUnassignedUsers()...');
      final unassignedUsers = await AuthService.getUnassignedUsers();
      print('   ✅ getUnassignedUsers returned ${unassignedUsers.length} users');
      
      print('   📊 User roles:');
      for (var user in users) {
        print('      - ${user.displayName}: ${user.role.name}');
      }
      
      print('   📊 Unassigned users:');
      for (var user in unassignedUsers) {
        print('      - ${user.displayName}: ${user.role.name}');
      }
      
      setState(() {
        _users = users;
        _unassignedUsers = unassignedUsers;
        _isLoading = false;
      });
      
      print('   ✅ setState completed with ${_users.length} users and ${_unassignedUsers.length} unassigned');
      
      // Show notification if there are unassigned users
      if (unassignedUsers.isNotEmpty && mounted) {
        NotificationService.showPendingUsersNotification(context, unassignedUsers.length);
      }
    } catch (e) {
      print('   ❌ Error in _loadUsers: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading users: ${e.toString()}',
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
  }

  List<UserProfile> get _filteredUsers {
    switch (_selectedFilter) {
      case 'unassigned':
        return _unassignedUsers;
      case 'all':
      default:
        return _users;
    }
  }

  Future<void> _assignRole(UserProfile user) async {
    print('🎯 Starting role assignment for user: ${user.displayName}');
    
    UserRole? selectedRole = await showDialog<UserRole>(
      context: context,
      builder: (context) => _RoleAssignmentDialog(user: user),
    );

    if (selectedRole != null) {
      print('   Selected role: ${selectedRole.name}');
      
      setState(() {
        _isAssigningRole = true;
      });
      
      try {
        print('   Calling AuthService.assignUserRole...');
        final success = await AuthService.assignUserRole(
          targetUserId: user.id,
          newRole: selectedRole,
        );

        print('   Role assignment result: $success');

        if (success) {
          print('   ✅ Role assignment successful, showing success message...');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Role assigned successfully to ${user.displayName}',
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
          
          print('   🔄 Refreshing user list...');
          // Refresh the user list to show updated data
          await _loadUsers();
          print('   ✅ User list refreshed');
          
        } else {
          print('   ❌ Role assignment failed');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to assign role',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        print('   ❌ Error during role assignment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error assigning role: ${e.toString()}',
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
      } finally {
        print('   🔄 Setting _isAssigningRole to false');
        setState(() {
          _isAssigningRole = false;
        });
      }
    } else {
      print('   ❌ No role selected, cancelling assignment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Alert for unassigned users
                if (_unassignedUsers.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_unassignedUsers.length} user(s) awaiting role assignment',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'unassigned';
                            });
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
                
                // Filter Tabs
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildFilterChip('All Users', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending Approval', 'unassigned'),
                    ],
                  ),
                ),

                // Statistics
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard('Total Users', _users.length.toString()),
                      const SizedBox(width: 12),
                      _buildStatCard('Pending', _unassignedUsers.length.toString()),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Users List
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
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
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
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
                color: AppColors.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.displayName ?? 'No Name',
          style: const TextStyle(
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
                color: AppColors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.toDisplayString(),
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: user.isUnassigned
            ? ElevatedButton(
                onPressed: _isAssigningRole ? null : () => _assignRole(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isAssigningRole 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Assign Role'),
              )
            : IconButton(
                onPressed: _isAssigningRole ? null : () => _assignRole(user),
                icon: _isAssigningRole 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : const Icon(Icons.edit),
                color: AppColors.primary,
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.onBackground.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'unassigned' 
                ? 'No pending users'
                : 'No users found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.salesRep:
        return Colors.blue;
      case UserRole.technician:
        return Colors.green;
      case UserRole.unassigned:
        return Colors.grey;
    }
  }
}

class _RoleAssignmentDialog extends StatefulWidget {
  final UserProfile user;

  const _RoleAssignmentDialog({required this.user});

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
              color: AppColors.onBackground.withOpacity(0.7),
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
        ElevatedButton(
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
