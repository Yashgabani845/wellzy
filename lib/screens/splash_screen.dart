import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/widgets/app_logo.dart';
import 'package:healthify/core/services/secure_storage_service.dart' as healthify_storage;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.forward().then((_) {
      _controller.repeat(reverse: true);
    });

    // Check auth status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    // Slight delay for smooth visual transition
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authController = Get.find<AuthController>();
    // Wait for the auth controller to finish its initial restoration (it runs onInit)
    while (authController.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    // We can also double check secure storage directly if needed, 
    // but authController already did it in restoreSession().
    
    // Import SecureStorageService to check first launch
    // (Ensure you add the import if not present, I'll assume we can just use the controller's knowledge)
    // Wait, AuthController doesn't know about firstLaunch. Let's check it directly.
    final storageService = Get.put(healthify_storage.SecureStorageService());
    final isFirstLaunch = await storageService.isFirstLaunch();

    if (!mounted) return;

    if (authController.currentUser != null) {
      if (authController.onboardingCompleted) {
        context.go(AppRoutes.main);
      } else {
        context.go(AppRoutes.onboarding);
      }
    } else {
      if (isFirstLaunch) {
        context.go(AppRoutes.featuresIntro);
      } else {
        context.go(AppRoutes.auth);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFloatingIcon(String emoji, double left, double top, double size, double opacity, {double rotation = 0}) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value * (size / 50)),
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: size),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFF0FFF0), Colors.white], // Light greenish to white
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
          
          // Glowing Circles in Center
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),

          // Floating Background Elements (Fruits & Veggies)
          _buildFloatingIcon('🥑', size.width * 0.15, size.height * 0.15, 60, 0.4, rotation: -0.2),
          _buildFloatingIcon('🍏', size.width * 0.75, size.height * 0.25, 50, 0.35, rotation: 0.3),
          _buildFloatingIcon('🍃', size.width * 0.65, size.height * 0.75, 80, 0.25, rotation: 0.5),
          _buildFloatingIcon('🌿', size.width * 0.2, size.height * 0.65, 70, 0.3, rotation: -0.4),
          _buildFloatingIcon('🥒', size.width * 0.8, size.height * 0.1, 40, 0.3, rotation: 0.1),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const AppLogo(size: 100, showText: false),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Wellzy',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Eat Smarter. Live Better.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator at bottom
          Positioned(
            bottom: size.height * 0.1,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
