import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/customer_service.dart';
import '../../../../core/services/order_service.dart';

/// Provider for dashboard tab selection state
class DashboardTabNotifier extends StateNotifier<int> {
  DashboardTabNotifier() : super(0);

  void setTab(int index) {
    state = index;
  }
}

final dashboardTabProvider =
    StateNotifierProvider<DashboardTabNotifier, int>((ref) {
  return DashboardTabNotifier();
});

/// Provider for unassigned users with AsyncValue
class UnassignedUsersNotifier extends AsyncNotifier<List<UserProfile>> {
  @override
  Future<List<UserProfile>> build() async {
    return await _loadUnassignedUsers();
  }

  Future<List<UserProfile>> _loadUnassignedUsers() async {
    try {
      return await AuthService.getUnassignedUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadUnassignedUsers());
  }
}

final unassignedUsersProvider =
    AsyncNotifierProvider<UnassignedUsersNotifier, List<UserProfile>>(() {
  return UnassignedUsersNotifier();
});

/// Provider for order statistics with AsyncValue
class OrderStatisticsNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    return await _loadOrderStatistics();
  }

  Future<int> _loadOrderStatistics() async {
    try {
      return await OrderService.getActiveOrdersCount();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadOrderStatistics());
  }
}

final orderStatisticsProvider =
    AsyncNotifierProvider<OrderStatisticsNotifier, int>(() {
  return OrderStatisticsNotifier();
});

/// Provider for active orders list with AsyncValue
class ActiveOrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    return await _loadActiveOrders();
  }

  Future<List<Order>> _loadActiveOrders() async {
    try {
      return await OrderService.getActiveOrders();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadActiveOrders());
  }
}

final activeOrdersProvider =
    AsyncNotifierProvider<ActiveOrdersNotifier, List<Order>>(() {
  return ActiveOrdersNotifier();
});
