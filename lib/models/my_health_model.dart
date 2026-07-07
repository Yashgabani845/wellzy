class MedicalProfileModel {
  final String bloodGroup;
  final String diet;
  final String allergies;
  final String conditions;
  final String goal;

  MedicalProfileModel({
    required this.bloodGroup,
    required this.diet,
    required this.allergies,
    required this.conditions,
    required this.goal,
  });

  factory MedicalProfileModel.fromMap(Map<String, dynamic> map) {
    return MedicalProfileModel(
      bloodGroup: map['bloodGroup'] ?? 'O+',
      diet: map['diet'] ?? 'Vegetarian',
      allergies: map['allergies'] ?? 'None',
      conditions: map['conditions'] ?? 'None',
      goal: map['goal'] ?? 'Weight Loss',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodGroup': bloodGroup,
      'diet': diet,
      'allergies': allergies,
      'conditions': conditions,
      'goal': goal,
    };
  }
}

class MyHealthData {
  final int healthScore;
  final String healthScoreGrade; // e.g., Excellent, Good, Fair, Poor
  final int healthScoreWeeklyDiff; // e.g., +3

  // Body Composition
  final double currentWeight;
  final double goalWeight;
  final double bmi;
  final String bmiCategory;
  final String weightTrendMsg;

  // Nutrition Quality Grades
  final String proteinGrade;
  final String fiberGrade;
  final String fatGrade;
  final String sugarGrade;
  final String sodiumGrade;
  final int nutritionQualityStars;

  // Daily Nutrition Breakdown (Ratios/Percentages)
  final double proteinPercent;
  final double fiberPercent;
  final double waterPercent;
  final double sugarPercent;
  final double caloriesPercent;

  // Nutrition Balance
  final String carbsBalance;
  final String proteinBalance;
  final String fatBalance;
  final String fiberBalance;
  final String sugarBalance;
  final String sodiumBalance;

  // Nutrient Gaps
  final List<String> nutrientGapsLow;
  final List<String> nutrientGapsGood;
  final List<String> nutrientGapsIncrease;

  // Eating Pattern Analysis
  final Map<String, String> mealPatterns; // e.g., {"Breakfast": "Skipped 4 Days", "Lunch": "Consistent"}

  // Food Quality Analysis
  final double wholeFoodRatio;
  final double processedFoodRatio;
  final double ultraProcessedRatio;
  final String foodQualityFeedback;

  // Lifestyle Assessment
  final Map<String, double> lifestyleRatings; // e.g., {"Hydration": 5.0, "Nutrition": 4.0}

  // Smart Insights
  final List<String> smartInsights;

  // Personalized Recommendations
  final List<String> personalizedRecommendations;

  // Health Risk Indicators
  final List<Map<String, dynamic>> healthRiskIndicators; // e.g., [{"title": "High Sodium Intake", "days": 6}]

  // Health Timeline
  final Map<String, dynamic> healthTimeline;

  // Medical Profile
  final MedicalProfileModel medicalProfile;

  // Achievements
  final List<Map<String, dynamic>> wellnessAchievements;

  MyHealthData({
    required this.healthScore,
    required this.healthScoreGrade,
    required this.healthScoreWeeklyDiff,
    required this.currentWeight,
    required this.goalWeight,
    required this.bmi,
    required this.bmiCategory,
    required this.weightTrendMsg,
    required this.proteinGrade,
    required this.fiberGrade,
    required this.fatGrade,
    required this.sugarGrade,
    required this.sodiumGrade,
    required this.nutritionQualityStars,
    required this.proteinPercent,
    required this.fiberPercent,
    required this.waterPercent,
    required this.sugarPercent,
    required this.caloriesPercent,
    required this.carbsBalance,
    required this.proteinBalance,
    required this.fatBalance,
    required this.fiberBalance,
    required this.sugarBalance,
    required this.sodiumBalance,
    required this.nutrientGapsLow,
    required this.nutrientGapsGood,
    required this.nutrientGapsIncrease,
    required this.mealPatterns,
    required this.wholeFoodRatio,
    required this.processedFoodRatio,
    required this.ultraProcessedRatio,
    required this.foodQualityFeedback,
    required this.lifestyleRatings,
    required this.smartInsights,
    required this.personalizedRecommendations,
    required this.healthRiskIndicators,
    required this.healthTimeline,
    required this.medicalProfile,
    required this.wellnessAchievements,
  });
}
