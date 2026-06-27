import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/widgets/dashboard/add_entry_bottom_sheet.dart';

import 'dashboard/dashboard_screen.dart';
import 'diary/diary_screen.dart';
import 'progress/progress_screen.dart';
import 'profile/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DiaryScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEntryBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntrySheet,
        backgroundColor: AppColors.primaryDark,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0),
              _buildNavItem(icon: Icons.book_rounded, label: 'Diary', index: 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(icon: Icons.bar_chart_rounded, label: 'Progress', index: 2),
              _buildNavItem(icon: Icons.person_rounded, label: 'Profile', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
