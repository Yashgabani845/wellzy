import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/controllers/profile_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── App Bar ──────────────────────────────────────────────
              const SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                title: Text('Profile', style: AppTextStyles.sectionHeading),
              ),

              // ─── Content ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section
                      _buildHeroSection(controller),
                      const SizedBox(height: 32),

                      // Stats Grid
                      _buildStatsGrid(controller),
                      const SizedBox(height: 32),

                      // Settings List
                      _buildSettingsSection(controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Hero Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSection(ProfileController controller) {
    final profile = controller.profile;
    if (profile == null) return const SizedBox.shrink();

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Avatar
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(profile.avatarUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name and Pro badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profile.name, style: AppTextStyles.largeHeading.copyWith(fontSize: 24)),
              if (profile.isPro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Joined Date
          Text(
            'Member since ${profile.joinedDate.year}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Edit Button
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Stats Grid
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsGrid(ProfileController controller) {
    final stats = controller.stats;
    if (stats == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Current Weight', '${stats.currentWeight} kg', Icons.monitor_weight_outlined, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Goal Weight', '${stats.goalWeight} kg', Icons.flag_outlined, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Active Streak', '${stats.streakDays} Days', Icons.local_fire_department_outlined, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Workouts', '${stats.totalWorkouts}', Icons.fitness_center_outlined, Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Settings List
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSettingsSection(ProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.star_border,
              title: 'Subscription',
              subtitle: 'Healthify Pro',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          const Text('Preferences', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsToggle(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: controller.isDarkMode,
              onChanged: controller.toggleTheme,
            ),
            _buildSettingsToggle(
              icon: Icons.straighten,
              title: 'Use Metric System (kg/ml)',
              value: controller.useMetric,
              onChanged: controller.toggleUnits,
            ),
          ]),
          const SizedBox(height: 24),
          const Text('Notifications', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsToggle(
              icon: Icons.water_drop_outlined,
              title: 'Water Reminders',
              value: controller.waterReminders,
              onChanged: controller.toggleWaterReminders,
            ),
            _buildSettingsToggle(
              icon: Icons.fitness_center_outlined,
              title: 'Workout Reminders',
              value: controller.workoutReminders,
              onChanged: controller.toggleWorkoutReminders,
            ),
          ]),
          const SizedBox(height: 32),
          // Logout Button
          Center(
            child: TextButton(
              onPressed: () async {
                final authController = Get.find<AuthController>();
                await authController.logout();
                if (context.mounted) {
                  context.go(AppRoutes.auth);
                }
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
