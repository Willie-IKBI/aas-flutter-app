import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/auth_service.dart';

// User Management State
class UserManagementState {
  const UserManagementState({
    this.users = const [],
    this.unassignedUsers = const [],
    this.isLoading = false,
    this.isAssigningRole = false,
    this.selectedFilter = 'all',
    this.searchQuery = '',
    this.selectedUserIds = const {},
    this.isMultiSelectMode = false,
    this.sortBy = 'name',
    this.sortAscending = true,
    this.error,
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.isLoadingMore = false,
  });
  final List<UserProfile> users;
  final List<UserProfile> unassignedUsers;
  final bool isLoading;
  final bool isAssigningRole;
  final String selectedFilter;
  final String searchQuery;
  final Set<String> selectedUserIds;
  final bool isMultiSelectMode;
  final String sortBy;
  final bool sortAscending;
  final String? error;
  final int currentPage;
  final int itemsPerPage;
  final bool isLoadingMore;

  UserManagementState copyWith({
    List<UserProfile>? users,
    List<UserProfile>? unassignedUsers,
    bool? isLoading,
    bool? isAssigningRole,
    String? selectedFilter,
    String? searchQuery,
    Set<String>? selectedUserIds,
    bool? isMultiSelectMode,
    String? sortBy,
    bool? sortAscending,
    String? error,
    int? currentPage,
    int? itemsPerPage,
    bool? isLoadingMore,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      unassignedUsers: unassignedUsers ?? this.unassignedUsers,
      isLoading: isLoading ?? this.isLoading,
      isAssigningRole: isAssigningRole ?? this.isAssigningRole,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  // Computed properties
  List<UserProfile> get filteredUsers {
    List<UserProfile> baseUsers;
    switch (selectedFilter) {
      case 'unassigned':
        baseUsers = unassignedUsers;
        break;
      case 'all':
      default:
        baseUsers = users;
        break;
    }

    // Apply search filter
    var filteredUsers = baseUsers;
    if (searchQuery.isNotEmpty) {
      filteredUsers = baseUsers.where((user) {
        final name = (user.displayName ?? '').toLowerCase();
        final email = (user.email ?? '').toLowerCase();
        final role = user.role.toDisplayString().toLowerCase();

        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            role.contains(searchQuery);
      }).toList();
    }

    // Apply sorting
    filteredUsers.sort((a, b) {
      var comparison = 0;
      switch (sortBy) {
        case 'name':
          comparison = (a.displayName ?? a.email ?? '')
              .compareTo(b.displayName ?? b.email ?? '');
          break;
        case 'email':
          comparison = (a.email ?? '').compareTo(b.email ?? '');
          break;
        case 'role':
          comparison =
              a.role.toDisplayString().compareTo(b.role.toDisplayString());
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return filteredUsers;
  }

  // Paginated users
  List<UserProfile> get paginatedUsers {
    final filtered = filteredUsers;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filtered.length);

    if (startIndex >= filtered.length) return [];

    return filtered.sublist(startIndex, endIndex);
  }

  // Pagination info
  int get totalPages => (filteredUsers.length / itemsPerPage).ceil();
  int get totalFilteredUsers => filteredUsers.length;

  bool get hasError => error != null;
  bool get hasUnassignedUsers => unassignedUsers.isNotEmpty;
  int get selectedCount => selectedUserIds.length;
  bool get isAllSelected =>
      selectedUserIds.length == filteredUsers.length &&
      filteredUsers.isNotEmpty;
}

// User Management Notifier
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(const UserManagementState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);

    try {
      final users = await AuthService.getAllUsers();
      final unassignedUsers = await AuthService.getUnassignedUsers();

      state = state.copyWith(
        users: users,
        unassignedUsers: unassignedUsers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
  }

  void setSelectedFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  void toggleMultiSelectMode() {
    state = state.copyWith(
      isMultiSelectMode: !state.isMultiSelectMode,
      selectedUserIds: state.isMultiSelectMode ? {} : state.selectedUserIds,
    );
  }

  void toggleUserSelection(String userId) {
    final newSelection = Set<String>.from(state.selectedUserIds);
    if (newSelection.contains(userId)) {
      newSelection.remove(userId);
    } else {
      newSelection.add(userId);
    }
    state = state.copyWith(selectedUserIds: newSelection);
  }

  void selectAllUsers() {
    state = state.copyWith(
      selectedUserIds: state.filteredUsers.map((user) => user.id).toSet(),
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedUserIds: {});
  }

  Future<void> assignRole(UserProfile user, UserRole role) async {
    state = state.copyWith(isAssigningRole: true);

    try {
      final success = await AuthService.assignUserRole(
        targetUserId: user.id,
        newRole: role,
      );

      if (success) {
        await loadUsers(); // Refresh the user list
      } else {
        state = state.copyWith(
          isAssigningRole: false,
          error: 'Failed to assign role',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAssigningRole: false,
        error: e.toString(),
      );
    }
  }

  Future<void> bulkAssignRole(UserRole role) async {
    if (state.selectedUserIds.isEmpty) return;

    state = state.copyWith(isAssigningRole: true);

    var successCount = 0;
    var failCount = 0;

    for (final userId in state.selectedUserIds) {
      try {
        final success = await AuthService.assignUserRole(
          targetUserId: userId,
          newRole: role,
        );
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      }
    }

    state = state.copyWith(
      isAssigningRole: false,
      selectedUserIds: {},
      isMultiSelectMode: false,
    );

    await loadUsers(); // Refresh the user list

    if (failCount > 0) {
      state = state.copyWith(
        error:
            'Bulk assignment completed: $successCount successful, $failCount failed',
      );
    }
  }

  void clearError() {
    state = state.copyWith();
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setItemsPerPage(int itemsPerPage) {
    state = state.copyWith(
      itemsPerPage: itemsPerPage,
      currentPage: 1, // Reset to first page when changing items per page
    );
  }

  void goToNextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void goToPreviousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  Future<void> updateUserDisplayName(
      String userId, String newDisplayName) async {
    state = state.copyWith(isAssigningRole: true);

    try {
      final success = await AuthService.updateUserProfile(
        targetUserId: userId,
        displayName: newDisplayName,
      );

      if (success) {
        await loadUsers(); // Refresh the user list
        state = state.copyWith(isAssigningRole: false);
      } else {
        state = state.copyWith(
          isAssigningRole: false,
          error: 'Failed to update display name',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAssigningRole: false,
        error: e.toString(),
      );
    }
  }
}

// Providers
final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>(
  (ref) => UserManagementNotifier(),
);

// Computed providers
final filteredUsersProvider = Provider<List<UserProfile>>((ref) {
  return ref.watch(userManagementProvider).filteredUsers;
});

final paginatedUsersProvider = Provider<List<UserProfile>>((ref) {
  return ref.watch(userManagementProvider).paginatedUsers;
});

final hasUnassignedUsersProvider = Provider<bool>((ref) {
  return ref.watch(userManagementProvider).hasUnassignedUsers;
});

final selectedCountProvider = Provider<int>((ref) {
  return ref.watch(userManagementProvider).selectedCount;
});

final isAllSelectedProvider = Provider<bool>((ref) {
  return ref.watch(userManagementProvider).isAllSelected;
});

final paginationInfoProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(userManagementProvider);
  return {
    'currentPage': state.currentPage,
    'totalPages': state.totalPages,
    'totalItems': state.totalFilteredUsers,
    'itemsPerPage': state.itemsPerPage,
  };
});
