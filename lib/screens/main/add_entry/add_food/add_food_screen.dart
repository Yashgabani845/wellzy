import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/food_controller.dart';
import 'package:healthify/models/food_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final FoodController _controller = Get.put(FoodController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FoodController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Add Food', style: AppTextStyles.sectionHeading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Column(
            children: [
              // ─── Meal Type Selector ─────────────────────
              _buildMealTypeSelector(controller),
              const SizedBox(height: 16),

              // ─── Search Bar ─────────────────────────────
              _buildSearchBar(controller),
              const SizedBox(height: 16),

              // ─── Content ────────────────────────────────
              Expanded(
                child: controller.hasActiveSearch
                    ? _buildSearchResults(controller)
                    : _buildRecommendations(controller),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Meal Type Pills
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMealTypeSelector(FoodController controller) {
    final meals = [
      {'id': 'breakfast', 'label': 'Breakfast', 'icon': '🌅'},
      {'id': 'lunch', 'label': 'Lunch', 'icon': '☀️'},
      {'id': 'dinner', 'label': 'Dinner', 'icon': '🌆'},
      {'id': 'snack', 'label': 'Snack', 'icon': '🌙'},
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          final isSelected = controller.selectedMealType == meal['id'];
          return GestureDetector(
            onTap: () => controller.setMealType(meal['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: AppColors.border),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryDark.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  Text(meal['icon']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    meal['label']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Search Bar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchBar(FoodController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (value) => controller.search(value),
          decoration: InputDecoration(
            hintText: 'Search food (e.g. "chicken", "rice")',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: controller.hasActiveSearch
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      controller.search('');
                      _searchFocus.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Recommendations (default view)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecommendations(FoodController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequently Eaten', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 4),
            Text(
              'Based on your recent meals',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...controller.recommendations.map((food) => _buildFoodCard(controller, food)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Search Results
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchResults(FoodController controller) {
    if (controller.isSearching) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No food found for "${controller.searchQuery}"',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        return _buildFoodCard(controller, controller.searchResults[index]);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Food Card (shared between recommendations and search)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFoodCard(FoodController controller, FoodItem food) {
    return GestureDetector(
      onTap: () => _showFoodDetail(context, controller, food),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  _getCategoryEmoji(food.category),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${food.brand} · ${food.defaultServingGrams.toInt()}g serving',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            // Calorie badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.caloriesFor(food.defaultServingGrams).toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryDark),
                ),
                Text(
                  'kcal',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Fruits': return '🍎';
      case 'Grains': return '🌾';
      case 'Protein': return '🍗';
      case 'Dairy': return '🥛';
      case 'Snacks': return '🍿';
      default: return '🍽️';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Food Detail Bottom Sheet
  // ═══════════════════════════════════════════════════════════════
  void _showFoodDetail(BuildContext context, FoodController controller, FoodItem food) {
    controller.selectFood(food);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return GetBuilder<FoodController>(
          builder: (ctrl) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Food name + category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(_getCategoryEmoji(food.category), style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                              Text(food.brand, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Macro Summary Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroColumn('Calories', '${ctrl.totalCalories.toInt()}', 'kcal', AppColors.primaryDark),
                          _buildMacroDivider(),
                          _buildMacroColumn('Protein', ctrl.totalProtein.toStringAsFixed(1), 'g', const Color(0xFFE57373)),
                          _buildMacroDivider(),
                          _buildMacroColumn('Carbs', ctrl.totalCarbs.toStringAsFixed(1), 'g', const Color(0xFFFFB74D)),
                          _buildMacroDivider(),
                          _buildMacroColumn('Fat', ctrl.totalFat.toStringAsFixed(1), 'g', const Color(0xFF64B5F6)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Serving Size
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Serving Size', style: AppTextStyles.subSectionHeading),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextField(
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  controller: TextEditingController(text: ctrl.servingGrams.toInt().toString()),
                                  onChanged: (val) {
                                    final g = double.tryParse(val);
                                    if (g != null && g > 0) ctrl.setServingGrams(g);
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    suffixText: 'grams',
                                    suffixStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Quick serving chips
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildServingChip(ctrl, '½ serving', food.defaultServingGrams / 2),
                            _buildServingChip(ctrl, '1 serving', food.defaultServingGrams),
                            _buildServingChip(ctrl, '1½ serving', food.defaultServingGrams * 1.5),
                            _buildServingChip(ctrl, '2 servings', food.defaultServingGrams * 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Number of Servings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of Servings', style: AppTextStyles.subSectionHeading),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: ctrl.servings > 1 ? () => ctrl.setServings(ctrl.servings - 1) : null,
                                icon: const Icon(Icons.remove, size: 18),
                                color: AppColors.primaryDark,
                              ),
                              Text(
                                ctrl.servings.toString(),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              IconButton(
                                onPressed: () => ctrl.setServings(ctrl.servings + 1),
                                icon: const Icon(Icons.add, size: 18),
                                color: AppColors.primaryDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: ctrl.isLogging
                            ? null
                            : () async {
                                await ctrl.logFood();
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${food.name} added to ${ctrl.selectedMealType}!'),
                                      backgroundColor: AppColors.primaryDark,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: ctrl.isLogging
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                'Add to ${_capitalize(ctrl.selectedMealType)} · ${ctrl.totalCalories.toInt()} kcal',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => controller.clearSelection());
  }

  Widget _buildMacroColumn(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
        ),
        Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMacroDivider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _buildServingChip(FoodController ctrl, String label, double grams) {
    final isActive = (ctrl.servingGrams - grams).abs() < 1;
    return GestureDetector(
      onTap: () => ctrl.setServingGrams(grams),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
