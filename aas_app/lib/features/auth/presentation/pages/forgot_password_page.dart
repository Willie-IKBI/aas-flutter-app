import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../widgets/modern_auth_text_field.dart';
import '../widgets/modern_auth_button.dart';
import '../widgets/responsive_auth_layout.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.resetPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Password reset email sent! Please check your inbox.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
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

  void _resendEmail() {
    setState(() => _emailSent = false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAuthLayout(
      header: const AuthHeader(
        title: 'Reset Password',
        subtitle: 'Enter your email to receive reset instructions',
        icon: Icons.lock_reset,
      ),
      footer: _buildBackToSignIn(),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveAuthCard(
              child: _emailSent ? _buildSuccessView() : _buildResetForm(),
            ),
    );
  }

  Widget _buildResetForm() {
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
                    'We\'ll send you a link to reset your password',
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

          // Email field
          ModernAuthTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Reset button
          ModernAuthButton(
            text: 'Send Reset Link',
            onPressed: _isLoading ? null : _resetPassword,
            isLoading: _isLoading,
            icon: Icons.send,
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
          'Email Sent!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w700,
              ),
        ),

        const SizedBox(height: 12),

        // Instructions
        Text(
          'We\'ve sent a password reset link to:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),

        const SizedBox(height: 8),

        // Email display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            _emailController.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
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
                Icons.info_outline,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check your email and click the link to reset your password',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Resend button
        ModernAuthButton(
          text: 'Resend Email',
          onPressed: _resendEmail,
          icon: Icons.refresh,
          variant: ModernButtonVariant.outlined,
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
            'Remember your password? ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
          ),
          GestureDetector(
            onTap: _isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: Text(
              'Sign In',
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
