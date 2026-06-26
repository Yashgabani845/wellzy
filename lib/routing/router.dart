import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/screens/authentication/auth_screen.dart';
import 'package:healthify/screens/onboarding/onboarding_screen.dart';
import 'package:healthify/screens/onboarding/onboarding_success.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.auth,
  routes: [
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
          // Restart journey by returning to AuthScreen
          context.go(AppRoutes.auth);
        },
      ),
    ),
  ],
);
