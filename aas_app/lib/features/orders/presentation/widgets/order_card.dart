import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/stage_management_service.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showStageActions = true,
    this.onMoveToStage,
  });
  final Order order;
  final VoidCallback? onTap;
  final bool showStageActions;
  final Function(String)? onMoveToStage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Semantics(
        label: 'Order ${order.id}',
        hint: onTap != null ? 'Tap to view details' : null,
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildCustomerInfo(),
                const SizedBox(height: 8),
                _buildDescription(),
                const SizedBox(height: 8),
                _buildStatusAndDate(),
                if (showStageActions) ...[
                  const SizedBox(height: 8),
                  _buildStageActions(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '#${order.id}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const Spacer(),
        _buildPriorityBadge(),
      ],
    );
  }

  Widget _buildPriorityBadge() {
    // For now, we'll use a default priority since it's not in the Order model
    final color = AppColors.onBackground.withValues(alpha: 0.3);
    const text = 'Normal';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        Icon(
          Icons.business,
          size: 16,
          color: AppColors.onBackground.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            order.customerName ?? 'Unknown Customer',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      order.description ?? 'No description',
      style: TextStyle(
        fontSize: 13,
        color: AppColors.onBackground.withValues(alpha: 0.8),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusAndDate() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            order.status.toDisplayString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(order.createdAt),
          style: TextStyle(
            fontSize: 10,
            color: AppColors.onBackground.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStageActions(BuildContext context) {
    final currentStage = order.currentStage;
    final nextStage =
        StageManagementService.getNextStage(currentStage.toDatabaseString());
    final previousStage = StageManagementService.getPreviousStage(
        currentStage.toDatabaseString());

    return Row(
      children: [
        if (previousStage != null)
          Expanded(
            child: _buildStageButton(
              context,
              'Previous',
              previousStage,
              Icons.arrow_back,
              AppColors.warning,
            ),
          ),
        if (previousStage != null && nextStage != null)
          const SizedBox(width: 8),
        if (nextStage != null)
          Expanded(
            child: _buildStageButton(
              context,
              'Next',
              nextStage,
              Icons.arrow_forward,
              AppColors.success,
            ),
          ),
      ],
    );
  }

  Widget _buildStageButton(
    BuildContext context,
    String label,
    String stage,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => onMoveToStage?.call(stage),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
