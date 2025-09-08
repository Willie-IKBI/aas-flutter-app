import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/stage_management_service.dart';
import '../../../../core/theme/index.dart';
import '../providers/pipeline_provider.dart';
import 'order_card.dart';
import 'job_summary_dialog.dart';
import 'stage_details_modal.dart';

class PipelineBoard extends ConsumerWidget {
  const PipelineBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(pipelineErrorProvider);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading pipeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onBackground.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(pipelineProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildResponsivePipeline(context, ref);
  }

  Widget _buildResponsivePipeline(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);

    // Use the selected view mode
    switch (viewMode) {
      case PipelineViewMode.grid:
        return _buildGridLayout(context, ref, crossAxisCount: 4, maxRows: 2);
      case PipelineViewMode.mobile:
        return _buildMobileLayout(context, ref);
    }
  }

  Widget _buildGridLayout(
    BuildContext context,
    WidgetRef ref, {
    required int crossAxisCount,
    required int maxRows,
  }) {
    const stages = StageManagementService.stageFlow;
    final totalStages = stages.length;
    final stagesPerRow = crossAxisCount;
    final totalRows = (totalStages / stagesPerRow).ceil();
    final actualRows = totalRows > maxRows ? maxRows : totalRows;

    return SingleChildScrollView(
      child: Column(
        children: List.generate(actualRows, (rowIndex) {
          final startIndex = rowIndex * stagesPerRow;
          final endIndex = (startIndex + stagesPerRow).clamp(0, totalStages);
          final rowStages = stages.sublist(startIndex, endIndex);

          return Container(
            height: 350, // Reduced height to prevent layout issues
            margin: EdgeInsets.only(bottom: rowIndex < actualRows - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowStages.map((stage) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: rowStages.indexOf(stage) < rowStages.length - 1
                          ? 12
                          : 0,
                    ),
                    child: _buildStageColumn(context, ref, stage),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: StageManagementService.stageFlow.map((stage) {
          return Container(
            height: 350, // Fixed height for mobile layout
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildStageColumn(context, ref, stage),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStageColumn(BuildContext context, WidgetRef ref, String stage) {
    final orders = ref.watch(ordersByStageProvider(stage));
    final stageCounts = ref.watch(stageCountsProvider);
    final count = stageCounts[stage] ?? 0;

    return SizedBox(
      height: 350, // Fixed height to prevent layout issues
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStageHeader(stage, count),
          const SizedBox(height: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: orders.isEmpty
                  ? _buildEmptyStage(stage)
                  : _buildOrdersList(context, ref, orders, stage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageHeader(String stage, int count) {
    final displayName = StageManagementService.getStageDisplayName(stage);
    final color = StageManagementService.getStageColor(stage);
    final icon = StageManagementService.getStageIcon(stage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStage(String stage) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.onBackground.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No orders in this stage',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onBackground.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    WidgetRef ref,
    List<Order> orders,
    String stage,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildOrderCard(context, ref, order, stage),
        );
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    Order order,
    String currentStage,
  ) {
    return Draggable<Order>(
      data: order,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          child: OrderCard(
            order: order,
            onTap: () => _showOrderDetails(context, order),
            showStageActions: false,
          ),
        ),
      ),
      childWhenDragging: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.drag_indicator,
            color: AppColors.onBackground.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: DragTarget<Order>(
        onAcceptWithDetails: (details) {
          final draggedOrder = details.data;
          if (draggedOrder.id != order.id) {
            _moveOrderToStage(context, ref, draggedOrder, currentStage);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return OrderCard(
            order: order,
            onTap: () => _showOrderDetails(context, order),
            onMoveToStage: (newStage) => _moveOrderToStage(
              context,
              ref,
              order,
              newStage,
            ),
          );
        },
      ),
    );
  }

  void _moveOrderToStage(
    BuildContext context,
    WidgetRef ref,
    Order order,
    String newStage,
  ) {
    if (order.currentStage == newStage) return;

    // Check if the move is valid
    if (!StageManagementService.canMoveToStage(
        order.currentStage.toDatabaseString(), newStage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot move order from ${StageManagementService.getStageDisplayName(order.currentStage.toDatabaseString())} to ${StageManagementService.getStageDisplayName(newStage)}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show stage details modal
    showDialog(
      context: context,
      builder: (context) => StageDetailsModal(
        order: order,
        nextStage: newStage,
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    // Show job summary dialog
    showDialog(
      context: context,
      builder: (context) => JobSummaryDialog(order: order),
    );
  }
}
