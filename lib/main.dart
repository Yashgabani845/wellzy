import 'package:flutter/material.dart';
import 'package:healthify/routing/router.dart';
import 'package:healthify/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Healthify',
      debugShowCheckedModeBanner: false,
      theme: NutriTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
