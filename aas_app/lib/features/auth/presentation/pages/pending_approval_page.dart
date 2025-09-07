import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/responsive_auth_layout.dart';
import '../widgets/auth_header.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key, this.onRefresh});
  final VoidCallback? onRefresh;

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isCheckingRole = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });

      // If user now has a role, trigger refresh
      if (profile != null && !profile.isUnassigned) {
        widget.onRefresh?.call();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkRoleStatus() async {
    setState(() {
      _isCheckingRole = true;
    });

    try {
      await _loadUserProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checking for role assignment...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isCheckingRole = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAuthLayout(
      header: const AuthHeader(
        title: 'Access Pending',
        subtitle:
            'Your account is awaiting role assignment by an administrator.',
        icon: Icons.pending_actions,
      ),
      footer: _buildFooter(),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // User Info Card
        if (_userProfile != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Account Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                    'Name', _userProfile!.displayName ?? 'Not provided'),
                _buildInfoRow('Email', _userProfile!.email ?? 'Not provided'),
                _buildInfoRow('Status', 'Pending Approval'),
                _buildInfoRow('Joined', _formatDate(_userProfile!.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Contact Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.contact_support,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Need Help?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact your system administrator to request role assignment.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onBackground.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isCheckingRole ? null : _checkRoleStatus,
            icon: _isCheckingRole
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isCheckingRole ? 'Checking...' : 'Check Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onBackground.withValues(alpha: 0.7),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onBackground,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
