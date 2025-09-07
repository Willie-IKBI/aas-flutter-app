import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/config/supabase_config.dart';
import '../widgets/modern_auth_text_field.dart';
import '../widgets/modern_auth_button.dart';
import '../widgets/responsive_auth_layout.dart';
import '../widgets/auth_header.dart';

class PasswordResetConfirmPage extends ConsumerStatefulWidget {
  const PasswordResetConfirmPage({
    super.key,
    this.accessToken,
    this.refreshToken,
    this.token,
    this.code,
  });
  final String? accessToken;
  final String? refreshToken;
  final String? token;
  final String? code;

  @override
  ConsumerState<PasswordResetConfirmPage> createState() =>
      _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState
    extends ConsumerState<PasswordResetConfirmPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {}); // Rebuild to update password strength indicator
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update the password using Supabase auth
      final response = await AuthService.updatePassword(
        newPassword: _passwordController.text,
      );

      if (mounted) {
        setState(() => _isSuccess = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Password updated successfully! You can now sign in.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );

        // Navigate to sign in page after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.goToSignIn();
          }
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SupabaseConfig.handleError(error)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearUrlParameters() {
    // Note: URL parameter clearing is now handled by the router
    // This method is deprecated and will be removed in future versions
  }

  void _goToSignIn() {
    context.goToSignIn();
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strengthLevel = AuthService.getPasswordStrengthLevel(password);
    final strengthMessage = AuthService.getPasswordStrengthMessage(password);

    Color strengthColor;
    String strengthText;

    switch (strengthLevel) {
      case 0:
      case 1:
        strengthColor = AppColors.error;
        strengthText = 'Very Weak';
        break;
      case 2:
        strengthColor = AppColors.warning;
        strengthText = 'Weak';
        break;
      case 3:
        strengthColor = AppColors.warning;
        strengthText = 'Fair';
        break;
      case 4:
        strengthColor = AppColors.success;
        strengthText = 'Good';
        break;
      case 5:
        strengthColor = AppColors.success;
        strengthText = 'Strong';
        break;
      default:
        strengthColor = AppColors.error;
        strengthText = 'Very Weak';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            Text(
              strengthText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strengthLevel / 5,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
        if (strengthMessage.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            strengthMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: strengthColor,
                  fontSize: 11,
                ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAuthLayout(
      header: const AuthHeader(
        title: 'Set New Password',
        subtitle: 'Enter your new password to complete the reset',
        icon: Icons.lock_outline,
      ),
      footer: _isSuccess ? _buildBackToSignIn() : null,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveAuthCard(
              child: _isSuccess ? _buildSuccessView() : _buildPasswordForm(),
            ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your new password must be at least 8 characters long',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // New Password field
          ModernAuthTextField(
            controller: _passwordController,
            label: 'New Password',
            hint: 'Enter your new password',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Password must contain at least one uppercase letter';
              }
              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return 'Password must contain at least one lowercase letter';
              }
              if (!RegExp(r'\d').hasMatch(value)) {
                return 'Password must contain at least one number';
              }
              return null;
            },
          ),

          // Password strength indicator
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
          ],

          const SizedBox(height: 16),

          // Confirm Password field
          ModernAuthTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your new password',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            obscureText: _obscureConfirmPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Update button
          ModernAuthButton(
            text: 'Update Password',
            onPressed: _isLoading ? null : _updatePassword,
            isLoading: _isLoading,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.successGradient,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Success title
        Text(
          'Password Updated!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w700,
              ),
        ),

        const SizedBox(height: 12),

        // Success message
        Text(
          'Your password has been successfully updated. You can now sign in with your new password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Success info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.security,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your account is now secure with the new password',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackToSignIn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ready to sign in? ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
          ),
          GestureDetector(
            onTap: _goToSignIn,
            child: Text(
              'Sign In Now',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
