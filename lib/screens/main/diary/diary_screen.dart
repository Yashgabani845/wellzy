import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

import 'package:healthify/widgets/common/empty_state_widget.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Diary', style: AppTextStyles.sectionHeading),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: const Center(
        child: EmptyStateWidget(
          icon: Icons.book_outlined,
          title: 'Empty Diary',
          message: 'You have not added any diary entries yet. Start logging your thoughts and feelings.',
        ),
      ),
    );
  }
}
