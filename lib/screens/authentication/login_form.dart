import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_spacing.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/custom_textfield.dart';
import 'package:healthify/widgets/primary_button.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final authController = Get.find<AuthController>();
      final error = await authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          widget.onSubmit();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            labelText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          AppSpacing.gapHmd,
          CustomTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            labelText: 'Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          AppSpacing.gapHsm,
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset instructions sent to email.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.gapHlg,
          PrimaryButton(
            text: 'Login',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }
}
