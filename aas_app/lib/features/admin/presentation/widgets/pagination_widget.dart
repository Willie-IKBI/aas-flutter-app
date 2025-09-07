import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.onPrevious,
    this.onNext,
    this.onPageChanged,
  });
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items info
          Text(
            'Showing $startItem-$endItem of $totalItems users',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withValues(alpha: 0.7),
                ),
          ),

          // Pagination controls
          Row(
            children: [
              // Previous button
              IconButton(
                onPressed: currentPage > 1 ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous page',
              ),

              // Page numbers
              ..._buildPageNumbers(),

              // Next button
              IconButton(
                onPressed: currentPage < totalPages ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final pages = <Widget>[];
    const maxVisiblePages = 5;

    var startPage =
        (currentPage - maxVisiblePages / 2).ceil().clamp(1, totalPages);
    final endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);

    // Adjust start if we're near the end
    if (endPage - startPage < maxVisiblePages - 1) {
      startPage = (endPage - maxVisiblePages + 1).clamp(1, totalPages);
    }

    // Add first page and ellipsis if needed
    if (startPage > 1) {
      pages.add(_buildPageButton(1));
      if (startPage > 2) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('...'),
        ));
      }
    }

    // Add visible page numbers
    for (var i = startPage; i <= endPage; i++) {
      pages.add(_buildPageButton(i));
    }

    // Add ellipsis and last page if needed
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('...'),
        ));
      }
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page) {
    final isCurrentPage = page == currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isCurrentPage ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isCurrentPage ? null : () => onPageChanged?.call(page),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              page.toString(),
              style: TextStyle(
                color: isCurrentPage ? Colors.white : AppColors.onBackground,
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
