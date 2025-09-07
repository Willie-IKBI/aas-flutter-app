import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../widgets/modern_auth_text_field.dart';
import '../widgets/modern_auth_button.dart';
import '../widgets/responsive_auth_layout.dart';
import '../widgets/auth_header.dart';
import '../widgets/enhanced_typography.dart';
import '../widgets/accessibility_helpers.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

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
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the terms and conditions'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Debug logging
      final displayName = _fullNameController.text.trim();
      print('Signing up user: $displayName');

      await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userData: {
          'display_name': displayName,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Account created successfully! Please check your email to verify your account.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate back to sign in page
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return PolishComponents.loadingOverlay(
      isLoading: _isLoading,
      loadingMessage: 'Creating account...',
      child: ResponsiveAuthLayout(
        header: ReducedMotionAnimation(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const AuthHeader(
              title: 'Create Account',
              subtitle: 'Join us to get started with your account',
              icon: Icons.person_add,
            ),
          ),
        ),
        footer: ReducedMotionAnimation(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSignInLink(),
          ),
        ),
        child: ReducedMotionAnimation(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ResponsiveAuthCard(
                child: _buildSignUpForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name field
          Semantics(
            label: 'Full Name',
            hint: 'Enter your full name',
            textField: true,
            child: ModernAuthTextField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().split(' ').length < 2) {
                  return 'Please enter your first and last name';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

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
            hint: 'Create a strong password',
            textField: true,
            child: ModernAuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a strong password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
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
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                    .hasMatch(value)) {
                  return 'Password must contain uppercase, lowercase, and number';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          // Confirm Password field
          Semantics(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            textField: true,
            child: ModernAuthTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: Semantics(
                label:
                    _obscureConfirmPassword ? 'Show password' : 'Hide password',
                button: true,
                child: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
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
          ),

          const SizedBox(height: 24),

          // Terms and conditions
          Row(
            children: [
              Semantics(
                label: 'Agree to terms and conditions',
                value: _agreeToTerms ? 'checked' : 'unchecked',
                child: Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  checkColor: AppColors.onPrimary,
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                    children: const [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Sign up button
          ModernAuthButton(
            text: 'Create Account',
            onPressed: _isLoading ? null : _signUp,
            isLoading: _isLoading,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
          ),
          InteractiveText(
            text: 'Sign In',
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
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
    );
  }
}
