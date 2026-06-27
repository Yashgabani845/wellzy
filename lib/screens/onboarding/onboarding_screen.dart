import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/controller/onboarding_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/widgets/progress_header.dart';
import 'package:healthify/widgets/primary_button.dart';
import 'package:healthify/widgets/secondary_button.dart';

import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';
import 'onboarding_page4.dart';
import 'onboarding_page5.dart';
import 'onboarding_page6.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalSteps = 6;

  // Local state for onboarding selections
  String _selectedGoal = 'Lose Weight';
  String _selectedGender = 'Male';
  int _selectedAge = 25;
  double _currentHeight = 175.0; // cm
  double _currentWeight = 70.0; // kg
  bool _isHeightCm = true;
  bool _isWeightKg = true;
  double _targetWeight = 68.0; // kg
  String _selectedActivity = 'Moderately Active';
  List<String> _selectedDiets = ['No Preference'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getDataForPage(int page) {
    switch (page) {
      case 0:
        return {
          'goal': _selectedGoal,
          'goalQuestion': 'What is your goal?',
        };
      case 1:
        return {
          'gender': _selectedGender,
          'genderQuestion': 'Gender',
          'age': _selectedAge,
          'ageQuestion': 'Age',
        };
      case 2:
        return {
          'height': _currentHeight,
          'heightQuestion': 'Height',
          'weight': _currentWeight,
          'weightQuestion': 'Weight',
        };
      case 3:
        return {
          'targetWeight': _targetWeight,
          'targetWeightQuestion': 'Target Weight',
        };
      case 4:
        return {
          'activityLevel': _selectedActivity,
          'activityLevelQuestion': 'Activity Level',
        };
      case 5:
        return {
          'dietPreference': _selectedDiets,
          'dietPreferenceQuestion': 'Diet Preference',
        };
      default:
        return {};
    }
  }

  Map<String, dynamic> _getAllOnboardingData() {
    return {
      'goal': _selectedGoal,
      'goalQuestion': 'What is your goal?',
      'gender': _selectedGender,
      'genderQuestion': 'Gender',
      'age': _selectedAge,
      'ageQuestion': 'Age',
      'height': _currentHeight,
      'heightQuestion': 'Height',
      'weight': _currentWeight,
      'weightQuestion': 'Weight',
      'targetWeight': _targetWeight,
      'targetWeightQuestion': 'Target Weight',
      'activityLevel': _selectedActivity,
      'activityLevelQuestion': 'Activity Level',
      'dietPreference': _selectedDiets,
      'dietPreferenceQuestion': 'Diet Preference',
      'currentStep': 5,
    };
  }

  void _nextPage() async {
    final authController = Get.find<AuthController>();
    final onboardingController = Get.find<OnboardingController>();
    final uid = authController.currentUser?.uid;

    if (uid != null) {
      final pageData = _getDataForPage(_currentPage);
      if (_currentPage < _totalSteps - 1) {
        await onboardingController.saveStep(
          uid: uid,
          step: _currentPage,
          stepData: pageData,
        );
      } else {
        final allData = _getAllOnboardingData();
        await onboardingController.completeOnboarding(
          uid: uid,
          finalData: allData,
        );
      }
    }

    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        context.push(AppRoutes.success);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    final authController = Get.find<AuthController>();
    final onboardingController = Get.find<OnboardingController>();
    final uid = authController.currentUser?.uid;

    if (uid != null) {
      final allData = _getAllOnboardingData();
      await onboardingController.completeOnboarding(
        uid: uid,
        finalData: allData,
      );
    }

    if (mounted) {
      context.push(AppRoutes.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Header at Top
              ProgressHeader(
                currentStep: _currentPage,
                totalSteps: _totalSteps,
                onSkip: _skipOnboarding,
                showSkip: _currentPage == 3 || _currentPage == 5, // skip target weight or diet preference
              ),
              const SizedBox(height: 20),

              // Onboarding Pages in Center
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Force using bottom action buttons
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    OnboardingPage1(
                      selectedGoal: _selectedGoal,
                      onGoalSelected: (goal) {
                        setState(() {
                          _selectedGoal = goal;
                        });
                      },
                    ),
                    OnboardingPage2(
                      selectedGender: _selectedGender,
                      onGenderSelected: (gender) {
                        setState(() {
                          _selectedGender = gender;
                        });
                      },
                      selectedAge: _selectedAge,
                      onAgeSelected: (age) {
                        setState(() {
                          _selectedAge = age;
                        });
                      },
                    ),
                    OnboardingPage3(
                      currentHeight: _currentHeight,
                      currentWeight: _currentWeight,
                      isHeightCm: _isHeightCm,
                      isWeightKg: _isWeightKg,
                      onHeightChanged: (h, cm) {
                        setState(() {
                          _currentHeight = h;
                          _isHeightCm = cm;
                        });
                      },
                      onWeightChanged: (w, kg) {
                        setState(() {
                          _currentWeight = w;
                          _isWeightKg = kg;
                        });
                      },
                    ),
                    OnboardingPage4(
                      targetWeight: _targetWeight,
                      isWeightKg: _isWeightKg,
                      onTargetWeightChanged: (w) {
                        setState(() {
                          _targetWeight = w;
                        });
                      },
                    ),
                    OnboardingPage5(
                      selectedActivity: _selectedActivity,
                      onActivitySelected: (act) {
                        setState(() {
                          _selectedActivity = act;
                        });
                      },
                    ),
                    OnboardingPage6(
                      selectedDiets: _selectedDiets,
                      onDietsChanged: (diets) {
                        setState(() {
                          _selectedDiets = diets;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Back & Continue Controls at Bottom
              Row(
                children: [
                  if (_currentPage > 0) ...[
                    Expanded(
                      flex: 2,
                      child: SecondaryButton(
                        text: 'Back',
                        onPressed: _previousPage,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: 3,
                    child: PrimaryButton(
                      text: _currentPage == _totalSteps - 1 ? 'Calculate Goal' : 'Continue',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
