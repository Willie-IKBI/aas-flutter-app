import 'package:flutter/material.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user_role.dart';

class SalesRepStep extends StatefulWidget {
  const SalesRepStep({
    super.key,
    this.selectedSalesRep,
    required this.onSalesRepSelected,
  });
  final UserProfile? selectedSalesRep;
  final Function(UserProfile) onSalesRepSelected;

  @override
  State<SalesRepStep> createState() => _SalesRepStepState();
}

class _SalesRepStepState extends State<SalesRepStep> {
  List<UserProfile> _salesReps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalesReps();
  }

  Future<void> _loadSalesReps() async {
    try {
      final allUsers = await AuthService.getAllUsers();
      final salesReps = allUsers
          .where((user) =>
              user.role == UserRole.salesRep || user.role == UserRole.admin)
          .toList();
      setState(() {
        _salesReps = salesReps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading sales representatives: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.infoGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_pin,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sales Representative',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select a sales representative to assign to this order',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selected sales rep display
            if (widget.selectedSalesRep != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.infoGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (widget.selectedSalesRep!.displayName ?? 'U')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedSalesRep!.displayName ??
                                'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.selectedSalesRep!.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.selectedSalesRep!.email!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          widget.onSalesRepSelected(widget.selectedSalesRep!);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        tooltip: 'Change sales rep',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Sales reps list or loading/empty state
            if (_isLoading) ...[
              Container(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.glassGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading Sales Representatives...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_salesReps.isEmpty) ...[
              Container(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.glassGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Sales Representatives',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No sales representatives are currently available.\nPlease contact an administrator.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Available Sales Representatives',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _salesReps.length,
                  itemBuilder: (context, index) {
                    final salesRep = _salesReps[index];
                    final isSelected =
                        widget.selectedSalesRep?.id == salesRep.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.primaryGradient
                            : AppColors.glassGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.onSalesRepSelected(salesRep);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AppColors.infoGradient
                                        : AppColors.glassGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.outline
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (salesRep.displayName ?? 'U')[0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        salesRep.displayName ?? 'Unknown User',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      if (salesRep.email != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          salesRep.email!,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.9)
                                                : AppColors.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Refresh button
              if (_salesReps.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.glassGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _loadSalesReps,
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: AppColors.onSurface,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Refresh List',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
