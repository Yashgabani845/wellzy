import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/primary_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.dashboard_customize_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Wellzy Dashboard',
                style: AppTextStyles.largeHeading.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Logged in as: ${authController.currentUser?.email ?? 'Unknown User'}',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Card(
                color: AppColors.card,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome to your journey!',
                        style: AppTextStyles.subSectionHeading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your nutrition goals and activity baselines have been calculated. Soon, your customized daily logs will appear here.',
                        style: AppTextStyles.caption.copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Log Out',
                onPressed: () async {
                  await authController.logout();
                  if (context.mounted) {
                    context.go(AppRoutes.auth);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
