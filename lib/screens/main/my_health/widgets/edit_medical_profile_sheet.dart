import 'package:flutter/material.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class EditMedicalProfileSheet extends StatefulWidget {
  final MedicalProfileModel initialProfile;
  final Function(MedicalProfileModel) onSave;

  const EditMedicalProfileSheet({
    super.key,
    required this.initialProfile,
    required this.onSave,
  });

  @override
  State<EditMedicalProfileSheet> createState() => _EditMedicalProfileSheetState();
}

class _EditMedicalProfileSheetState extends State<EditMedicalProfileSheet> {
  late String _bloodGroup;
  late String _diet;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late String _goal;

  final List<String> _bloodGroups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
  final List<String> _diets = ['Vegetarian', 'Vegan', 'Non-Vegetarian', 'Jain', 'Keto', 'Gluten-Free'];
  final List<String> _goals = ['Weight Loss', 'Muscle Gain', 'Maintenance', 'Fitness Tracking'];

  @override
  void initState() {
    super.initState();
    _bloodGroup = widget.initialProfile.bloodGroup;
    _diet = widget.initialProfile.diet;
    _allergiesController = TextEditingController(text: widget.initialProfile.allergies);
    _conditionsController = TextEditingController(text: widget.initialProfile.conditions);
    _goal = widget.initialProfile.goal;
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Update Medical Profile',
              style: AppTextStyles.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Blood Group Selector
            const Text('Blood Group', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 8),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bloodGroups.length,
                itemBuilder: (context, index) {
                  final group = _bloodGroups[index];
                  final isSelected = _bloodGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(group),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : AppColors.border,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _bloodGroup = group);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Diet preference Selector
            const Text('Diet Preference', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _diets.map((dietOption) {
                final isSelected = _diet == dietOption;
                return ChoiceChip(
                  label: Text(dietOption),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _diet = dietOption);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Goal Selector
            const Text('Health Goal', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals.map((goalOption) {
                final isSelected = _goal == goalOption;
                return ChoiceChip(
                  label: Text(goalOption),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _goal = goalOption);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Allergies field
            const Text('Allergies', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 8),
            TextField(
              controller: _allergiesController,
              decoration: InputDecoration(
                hintText: 'e.g. Peanuts, Gluten, Dairy',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Conditions field
            const Text('Medical Conditions', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 8),
            TextField(
              controller: _conditionsController,
              decoration: InputDecoration(
                hintText: 'e.g. Diabetes, None, Hypertension',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = MedicalProfileModel(
                        bloodGroup: _bloodGroup,
                        diet: _diet,
                        allergies: _allergiesController.text.trim().isEmpty ? 'None' : _allergiesController.text.trim(),
                        conditions: _conditionsController.text.trim().isEmpty ? 'None' : _conditionsController.text.trim(),
                        goal: _goal,
                      );
                      widget.onSave(updated);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
