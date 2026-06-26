import 'package:flutter/material.dart';
import 'package:healthify/theme/app_spacing.dart';
import 'package:healthify/widgets/custom_textfield.dart';
import 'package:healthify/widgets/primary_button.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const SignupForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          widget.onSubmit();
        }
      });
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
            controller: _nameController,
            hintText: 'Enter your full name',
            labelText: 'Full Name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          AppSpacing.gapHmd,
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
            hintText: 'Create a password',
            labelText: 'Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please create a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          AppSpacing.gapHmd,
          CustomTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm your password',
            labelText: 'Confirm Password',
            prefixIcon: Icons.lock_clock_outlined,
            isPassword: true,
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
          AppSpacing.gapHlg,
          PrimaryButton(
            text: 'Create Account',
            isLoading: _isLoading,
            onPressed: _handleSignup,
          ),
        ],
      ),
    );
  }
}
