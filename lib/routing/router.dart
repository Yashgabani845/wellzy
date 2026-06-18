import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/screens/details_screen.dart';
import 'package:healthify/screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) => HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.details,
      builder: (BuildContext context, GoRouterState state) => const DetailsScreen(),
    ),
  ],
);
