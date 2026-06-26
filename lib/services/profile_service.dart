import 'package:healthify/models/profile_model.dart';

class ProfileService {
  // Replace with real API call
  Future<UserProfile> fetchUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserProfile(
      id: 'u123',
      name: 'Yash Gabani',
      email: 'yash@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=11', // Placeholder avatar
      joinedDate: DateTime(2023, 10, 15),
      isPro: true,
    );
  }

  // Replace with real API call
  Future<UserStats> fetchUserStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserStats(
      currentWeight: 72.5,
      goalWeight: 68.0,
      streakDays: 14,
      totalWorkouts: 42,
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Handle local token clearance and API logout
  }
}
