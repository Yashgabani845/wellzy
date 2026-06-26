import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    // Slight delay for smooth visual transition
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final authController = Get.find<AuthController>();
    await authController.restoreSession();

    if (!mounted) return;

    if (authController.currentUser != null) {
      if (authController.onboardingCompleted) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.auth);
      }
    } else {
      context.go(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(size: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
