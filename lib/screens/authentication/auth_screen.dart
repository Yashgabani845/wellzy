import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/app_logo.dart';
import 'package:healthify/widgets/auth_divider.dart';
import 'package:healthify/widgets/social_login_button.dart';
import 'login_form.dart';
import 'signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLoginSelected = true;

  void _onFormSubmitted() {
    // Navigate placeholder to Onboarding
    context.push(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Section
              const SizedBox(height: 12),
              const Center(child: AppLogo(size: 70)),
              const SizedBox(height: 10),
              Text(
                _isLoginSelected ? 'Welcome Back' : 'Create Account',
                style: AppTextStyles.largeHeading.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Your health journey starts here.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Segmented Control (toggles login/signup)
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginSelected = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: _isLoginSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isLoginSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Login',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isLoginSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginSelected = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: !_isLoginSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isLoginSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: !_isLoginSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Switch Forms with animated crossfade
              AnimatedCrossFade(
                firstChild: LoginForm(onSubmit: _onFormSubmitted),
                secondChild: SignupForm(onSubmit: _onFormSubmitted),
                crossFadeState: _isLoginSelected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
              ),

              // Divider & Google sign in (now below the login/password fields)
              const AuthDivider(),
              SocialLoginButton(
                onPressed: () {
                  // Mock Google Sign-In and navigate
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulating Google Sign-In...'),
                      duration: Duration(milliseconds: 600),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Future.delayed(const Duration(milliseconds: 600), _onFormSubmitted);
                },
              ),

              // Bottom Footer Section
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginSelected
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoginSelected = !_isLoginSelected;
                      });
                    },
                    child: Text(
                      _isLoginSelected ? 'Sign Up' : 'Login',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
