class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime joinedDate;
  final bool isPro;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.joinedDate,
    required this.isPro,
  });
}

class UserStats {
  final double currentWeight;
  final double goalWeight;
  final int streakDays;
  final int totalWorkouts;

  UserStats({
    required this.currentWeight,
    required this.goalWeight,
    required this.streakDays,
    required this.totalWorkouts,
  });
}
