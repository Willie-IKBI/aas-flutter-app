import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildSkeletonCircle(40),
        title: _buildSkeletonRectangle(120, 16),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildSkeletonRectangle(180, 14),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSkeletonRectangle(80, 20),
                const SizedBox(width: 8),
                _buildSkeletonRectangle(60, 20),
              ],
            ),
            const SizedBox(height: 8),
            _buildSkeletonRectangle(150, 12),
          ],
        ),
        trailing: _buildSkeletonRectangle(80, 32),
      ),
    );
  }

  Widget _buildSkeletonRectangle(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.onBackground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.onBackground.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}

class UserListSkeleton extends StatelessWidget {
  const UserListSkeleton({
    super.key,
    this.itemCount = 5,
  });
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const UserCardSkeleton(),
    );
  }
}
