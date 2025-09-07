import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/modern_auth_text_field.dart';
import '../widgets/modern_auth_button.dart';

import '../widgets/responsive_auth_layout.dart';
import '../widgets/auth_header.dart';
import '../widgets/enhanced_typography.dart';
import '../../../../core/widgets/accessibility_helpers.dart';
import 'sign_up_page.dart';
import 'forgot_password_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      // Announce validation error to screen readers
      AccessibilityHelpers.announce(
        context,
        'Please fix the errors in the form',
        textDirection: TextDirection.ltr,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Show welcome message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Welcome back!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Wait a moment for auth state to propagate, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to dashboard
        if (mounted) {
          context.go('/dashboard');
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SupabaseConfig.handleError(error)),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  void _forgotPassword() {
    context.goToForgotPassword();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ResponsiveAuthLayout(
          header: FadeTransition(
            opacity: _fadeAnimation,
            child: const AuthHeader(
              title: 'Welcome Back',
              subtitle: 'Sign in to your account to continue',
              icon: Icons.construction,
            ),
          ),
          footer: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSignUpLink(),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ResponsiveAuthCard(
                child: _buildSignInForm(),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          Semantics(
            label: 'Email Address',
            hint: 'Enter your email address',
            textField: true,
            child: ModernAuthTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
          ),

          const SizedBox(height: 24),

          // Password field
          Semantics(
            label: 'Password',
            hint: 'Enter your password',
            textField: true,
            child: ModernAuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              suffixIcon: Semantics(
                label: _obscurePassword ? 'Show password' : 'Hide password',
                button: true,
                child: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Remember me and forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Semantics(
                    label: 'Remember me',
                    value: _rememberMe ? 'checked' : 'unchecked',
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      checkColor: AppColors.onPrimary,
                    ),
                  ),
                  Text(
                    'Remember me',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              Semantics(
                label: 'Forgot Password',
                button: true,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Sign in button
          ModernAuthButton(
            text: 'Sign In',
            onPressed: _isLoading ? null : _signIn,
            isLoading: _isLoading,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
          ),
          InteractiveText(
            text: 'Sign Up',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
            hoverStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
            onTap: _isLoading
                ? null
                : () {
                    context.goToSignUp();
                  },
          ),
        ],
      ),
    );
  }
}
