import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/screens/splash_screen.dart';
import 'package:healthify/screens/onboarding/feature_intro_screen.dart';
import 'package:healthify/screens/main/main_layout_screen.dart';
import 'package:healthify/screens/authentication/auth_screen.dart';
import 'package:healthify/screens/onboarding/onboarding_screen.dart';
import 'package:healthify/screens/onboarding/onboarding_success.dart';
import 'package:healthify/screens/main/add_entry/add_food/add_food_screen.dart';
import 'package:healthify/screens/main/add_entry/scan_barcode/scan_barcode_screen.dart';
import 'package:healthify/screens/main/add_entry/update_weight/update_weight_screen.dart';
import 'package:healthify/screens/main/add_entry/add_exercise/add_exercise_screen.dart';
import 'package:healthify/screens/main/add_entry/log_water/log_water_screen.dart';
import 'package:healthify/screens/main/add_entry/add_sleep/add_sleep_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.addFood,
      builder: (BuildContext context, GoRouterState state) {
        final mealType = state.uri.queryParameters['mealType'];
        return AddFoodScreen(mealType: mealType);
      },
    ),
    GoRoute(
      path: AppRoutes.scanBarcode,
      builder: (BuildContext context, GoRouterState state) => const ScanBarcodeScreen(),
    ),
    GoRoute(
      path: AppRoutes.updateWeight,
      builder: (BuildContext context, GoRouterState state) => const UpdateWeightScreen(),
    ),
    GoRoute(
      path: AppRoutes.addExercise,
      builder: (BuildContext context, GoRouterState state) => const AddExerciseScreen(),
    ),
    GoRoute(
      path: AppRoutes.logWater,
      builder: (BuildContext context, GoRouterState state) => const LogWaterScreen(),
    ),
    GoRoute(
      path: AppRoutes.addSleep,
      builder: (BuildContext context, GoRouterState state) => const AddSleepScreen(),
    ),
    GoRoute(
      path: AppRoutes.main,
      builder: (BuildContext context, GoRouterState state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.featuresIntro,
      builder: (BuildContext context, GoRouterState state) => const FeatureIntroScreen(),
    ),
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
  ],
);
