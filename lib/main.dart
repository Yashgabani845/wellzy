import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/controller/onboarding_controller.dart';
import 'package:healthify/routing/router.dart';
import 'package:healthify/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  // Initialize global controllers
  Get.put(AuthController(), permanent: true);
  Get.put(OnboardingController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Wellzy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      backButtonDispatcher: appRouter.backButtonDispatcher,
    );
  }
}
