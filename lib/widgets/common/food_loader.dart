import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';

class FoodLoader extends StatefulWidget {
  final String label;
  const FoodLoader({super.key, this.label = 'Cooking up results...'});

  @override
  State<FoodLoader> createState() => _FoodLoaderState();
}

class _FoodLoaderState extends State<FoodLoader> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  
  int _currentIconIndex = 0;
  int _currentMessageIndex = 0;
  Timer? _timer;

  final List<IconData> _icons = [
    Icons.restaurant,
    Icons.lunch_dining,
    Icons.soup_kitchen,
    Icons.dinner_dining,
    Icons.local_pizza,
    Icons.bakery_dining,
    Icons.egg_alt,
    Icons.ramen_dining,
    Icons.local_cafe,
    Icons.icecream,
  ];

  final List<String> _cookingMessages = [
    'Prepping fresh ingredients...',
    'Tossing the salad...',
    'Simmering the curry...',
    'Checking macro ratios...',
    'Measuring portions...',
    'Flipping some pancakes...',
    'Garnishing with herbs...',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();

    // Cycle items every 900ms
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        _animController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentIconIndex = (_currentIconIndex + 1) % _icons.length;
              if (timer.tick % 2 == 0) {
                _currentMessageIndex = (_currentMessageIndex + 1) % _cookingMessages.length;
              }
            });
            _animController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Outer Ring & Inner Pulsing Icon
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    _icons[_currentIconIndex],
                    size: 38,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Text Label
            Text(
              _cookingMessages[_currentMessageIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
