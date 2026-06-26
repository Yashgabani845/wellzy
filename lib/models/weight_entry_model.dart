class WeightEntry {
  final double weightKg;
  final DateTime date;
  final double? bmi;

  WeightEntry({
    required this.weightKg,
    required this.date,
    this.bmi,
  });
}

class WeightHistory {
  final double currentWeight;
  final double goalWeight;
  final double heightCm;
  final List<WeightEntry> entries;

  WeightHistory({
    required this.currentWeight,
    required this.goalWeight,
    required this.heightCm,
    required this.entries,
  });

  double get currentBmi {
    final heightM = heightCm / 100;
    return currentWeight / (heightM * heightM);
  }

  String get bmiCategory {
    final bmi = currentBmi;
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }
}
