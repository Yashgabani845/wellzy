import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/dashboard_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/widgets/common/empty_state_widget.dart';
import 'package:healthify/widgets/dashboard/meal_card.dart';
import 'package:healthify/widgets/dashboard/overview_card.dart';
import 'package:healthify/widgets/dashboard/water_card.dart';
import 'package:healthify/widgets/dashboard/weight_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GetBuilder<DashboardController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final data = controller.dashboardData!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  FadeSlideIn(
                    delay: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Good Morning,', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Row(
                              children: [
                                Text(data.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                const SizedBox(width: 8),
                                const Text('👋', style: TextStyle(fontSize: 24)),
                              ],
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: data.userAvatar.startsWith('http')
                              ? NetworkImage(data.userAvatar)
                              : AssetImage(data.userAvatar) as ImageProvider,
                          backgroundColor: AppColors.border,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Overview Card
                  FadeSlideIn(
                    delay: 100,
                    child: OverviewCard(data: data),
                  ),
                  const SizedBox(height: 20),

                  // Water and Weight Grid
                  FadeSlideIn(
                    delay: 200,
                    child: Row(
                      children: [
                        Expanded(child: SizedBox(height: 160, child: WaterCard(data: data.water))),
                        const SizedBox(width: 16),
                        Expanded(child: SizedBox(height: 160, child: WeightCard(data: data.weight))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Today's Meals
                  const FadeSlideIn(
                    delay: 300,
                    child: Text(
                      'Today\'s Meals',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (data.meals.isEmpty)
                    const FadeSlideIn(
                      delay: 350,
                      child: EmptyStateWidget(
                        icon: Icons.restaurant_menu,
                        title: 'No Meals Logged',
                        message: 'Log your first meal today to see it here!',
                      ),
                    )
                  else
                    ...data.meals.asMap().entries.map((entry) {
                      return FadeSlideIn(
                        delay: 350 + (entry.key * 50),
                        child: MealCard(meal: entry.value),
                      );
                    }),
                  
                  const SizedBox(height: 40), // Padding for bottom nav bar
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delay;

  const FadeSlideIn({super.key, required this.child, required this.delay});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

