import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/stage_management_service.dart';

// View mode enum
enum PipelineViewMode {
  grid, // 2x4 grid layout for desktop overview
  mobile, // Single column optimized for mobile
}

// Pipeline state
class PipelineState {
  const PipelineState({
    this.ordersByStage = const {},
    this.stageCounts = const {},
    this.isLoading = false,
    this.error,
    this.selectedOrderId,
    this.viewMode = PipelineViewMode.grid,
  });
  final Map<String, List<Order>> ordersByStage;
  final Map<String, int> stageCounts;
  final bool isLoading;
  final String? error;
  final String? selectedOrderId;
  final PipelineViewMode viewMode;

  PipelineState copyWith({
    Map<String, List<Order>>? ordersByStage,
    Map<String, int>? stageCounts,
    bool? isLoading,
    String? error,
    String? selectedOrderId,
    PipelineViewMode? viewMode,
  }) {
    return PipelineState(
      ordersByStage: ordersByStage ?? this.ordersByStage,
      stageCounts: stageCounts ?? this.stageCounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedOrderId: selectedOrderId ?? this.selectedOrderId,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

// Pipeline notifier
class PipelineNotifier extends StateNotifier<PipelineState> {
  PipelineNotifier() : super(const PipelineState()) {
    loadPipelineData();
  }

  Future<void> loadPipelineData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load orders for each stage
      final ordersByStage = <String, List<Order>>{};
      final stageCounts = await StageManagementService.getStageCounts();

      for (final stage in StageManagementService.stageFlow) {
        final orders = await StageManagementService.getOrdersByStage(stage);
        ordersByStage[stage] = orders;
      }

      state = state.copyWith(
        ordersByStage: ordersByStage,
        stageCounts: stageCounts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading pipeline: ${e.toString()}',
      );
    }
  }

  Future<void> moveOrderToStage(
    int orderId,
    String newStage, {
    String? notes,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final success = await StageManagementService.moveOrderToStage(
        orderId,
        newStage,
        notes: notes,
        payload: payload,
      );

      if (success) {
        // Reload the pipeline data
        await loadPipelineData();
      } else {
        state = state.copyWith(
            error: 'Failed to move order $orderId to stage $newStage');
      }
    } catch (e) {
      state = state.copyWith(error: 'Error moving order: ${e.toString()}');
    }
  }

  void selectOrder(String? orderId) {
    state = state.copyWith(selectedOrderId: orderId);
  }

  void clearError() {
    state = state.copyWith();
  }

  void refresh() {
    clearError();
    loadPipelineData();
  }

  void toggleViewMode() {
    PipelineViewMode newViewMode;
    switch (state.viewMode) {
      case PipelineViewMode.grid:
        newViewMode = PipelineViewMode.mobile;
        break;
      case PipelineViewMode.mobile:
        newViewMode = PipelineViewMode.grid;
        break;
    }
    state = state.copyWith(viewMode: newViewMode);
  }

  void setViewMode(PipelineViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }
}

// Providers
final pipelineProvider =
    StateNotifierProvider<PipelineNotifier, PipelineState>((ref) {
  return PipelineNotifier();
});

// Individual stage providers
final ordersByStageProvider =
    Provider.family<List<Order>, String>((ref, stage) {
  final pipelineState = ref.watch(pipelineProvider);
  return pipelineState.ordersByStage[stage] ?? [];
});

final stageCountsProvider = Provider<Map<String, int>>((ref) {
  final pipelineState = ref.watch(pipelineProvider);
  return pipelineState.stageCounts;
});

final isLoadingProvider = Provider<bool>((ref) {
  final pipelineState = ref.watch(pipelineProvider);
  return pipelineState.isLoading;
});

final pipelineErrorProvider = Provider<String?>((ref) {
  final pipelineState = ref.watch(pipelineProvider);
  return pipelineState.error;
});

final selectedOrderProvider = Provider<String?>((ref) {
  final pipelineState = ref.watch(pipelineProvider);
  return pipelineState.selectedOrderId;
});

final viewModeProvider = Provider<PipelineViewMode>((ref) {
  final pipelineState = ref.watch(pipelineProvider);
  return pipelineState.viewMode;
});
