import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/screens/authentication/auth_screen.dart';
import 'package:healthify/screens/onboarding/onboarding_screen.dart';
import 'package:healthify/screens/onboarding/onboarding_success.dart';
import 'package:healthify/screens/splash_screen.dart';
import 'package:healthify/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (BuildContext context, GoRouterState state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.success,
      builder: (BuildContext context, GoRouterState state) => OnboardingSuccess(
        onStartJourney: () {
          // Log out first (as required by "Login Again" flow)
          Get.find<AuthController>().logout();
          context.go(AppRoutes.auth);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
    ),
  ],
);
