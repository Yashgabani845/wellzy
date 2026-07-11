import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:healthify/controllers/barcode_scanner_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/common/food_loader.dart';
import 'package:healthify/widgets/common/loading_overlay.dart';
import 'package:healthify/routing/routes.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.put(BarcodeScannerController());
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarcodeScannerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: controller.scannedFood != null
              ? AppColors.background
              : const Color(0xFFF9F9FB),
          appBar: AppBar(
            title: const Text('Scan Product Barcode', style: AppTextStyles.sectionHeading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            actions: [
              if (controller.scannedFood != null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                  tooltip: 'Scan Another',
                  onPressed: () {
                    controller.resetScanner();
                    _textController.clear();
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                            child: child,
                          ),
                        );
                      },
                      child: controller.scannedFood != null
                          ? _buildProductDetailsView(controller)
                          : _buildScannerView(controller),
                    ),
                  ),
                ],
              ),
              if (controller.isLogging)
                const Positioned.fill(
                  child: LoadingOverlay(message: 'Logging to Diary...'),
                ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Live Camera Scanner & Manual Input State View
  // ═══════════════════════════════════════════════════════════════
  Widget _buildScannerView(BarcodeScannerController controller) {
    if (!controller.isPermissionGranted) {
      return _buildPermissionRequiredView(controller);
    }

    if (controller.isFetching) {
      return const Center(child: FoodLoader(label: 'Fetching barcode details...'));
    }

    return Column(
      key: const ValueKey('scanner_view'),
      children: [
        // Camera Viewport
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.none,
            child: Stack(
              children: [
                if (controller.isCameraActive)
                  MobileScanner(
                    controller: _cameraController,
                    onDetect: (barcodeCapture) {
                      final List<Barcode> barcodes = barcodeCapture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final rawValue = barcodes.first.rawValue;
                        if (rawValue != null && rawValue.isNotEmpty) {
                          // Prevent duplicate processing while active
                          controller.fetchProduct(rawValue);
                        }
                      }
                    },
                  )
                else
                  Container(color: Colors.black),
                // Corner Frame Overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(),
                  ),
                ),
                // Red Scanning Laser Line (correctly constrained to the cutout area)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;
                      
                      final cutOutWidth = width * 0.75;
                      final cutOutHeight = width * 0.50;
                      final left = (width - cutOutWidth) / 2;
                      final top = (height - cutOutHeight) / 2.3;
                      
                      return Stack(
                        children: [
                          Positioned(
                            left: left,
                            top: top,
                            width: cutOutWidth,
                            height: cutOutHeight,
                            child: const ScanningLaserLine(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Hint overlay
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Align barcode inside the camera guidelines',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Manual Barcode Input
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR ENTER MANUALLY',
                        style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                    onChanged: (val) => controller.barcodeInput = val,
                    onSubmitted: (val) => controller.manualSearch(),
                    decoration: InputDecoration(
                      hintText: 'Enter barcode number (e.g. 890149...)',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, letterSpacing: 0),
                      prefixIcon: const Icon(Icons.qr_code_2, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryDark),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          controller.manualSearch();
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                if (controller.errorText != null)
                  _buildErrorCard(controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Camera Permission Warning Card View
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPermissionRequiredView(BarcodeScannerController controller) {
    return Center(
      key: const ValueKey('permission_view'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 24),
            const Text('Camera Permission Needed', style: AppTextStyles.largeHeading, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'We require camera access to automatically scan product barcodes for calories and nutrition lookup.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.settings, color: Colors.white),
                label: const Text('Grant Camera Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () => controller.requestPermission(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0), thickness: 1),
            const SizedBox(height: 16),
            const Text(
              'Alternatively, you can manually type below',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                onChanged: (val) => controller.barcodeInput = val,
                decoration: InputDecoration(
                  hintText: 'Enter barcode number...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, letterSpacing: 0),
                  prefixIcon: const Icon(Icons.qr_code_2, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryDark),
                    onPressed: () => controller.manualSearch(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            if (controller.errorText != null)
              _buildErrorCard(controller),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Scanned Product Details Form View
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProductDetailsView(BarcodeScannerController controller) {
    final food = controller.scannedFood!;

    // Prepopulate manual entry values on first display to avoid reset issues
    final TextEditingController gramsInputController = TextEditingController(
      text: controller.servingGrams.toInt().toString(),
    );

    return SingleChildScrollView(
      key: const ValueKey('details_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Glassmorphic Image & Title Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image View
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                      ? Image.network(
                          food.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Text(_getCategoryEmoji(food.category), style: const TextStyle(fontSize: 36))),
                        )
                      : Center(child: Text(_getCategoryEmoji(food.category), style: const TextStyle(fontSize: 36))),
                ),
                const SizedBox(width: 16),
                // Titles Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          food.category.toUpperCase(),
                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        food.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.brand,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Interactive Macro Display Panel
          const Text('Nutritional Info (per portion)', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Calories Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Calories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${controller.totalCalories.round()}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                        ),
                        const SizedBox(width: 4),
                        const Text('kcal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),
                // Macros Split Horizontal Gauges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMacroGauge('Protein', controller.totalProtein, const Color(0xFFE57373)),
                    _buildMacroGauge('Carbs', controller.totalCarbs, const Color(0xFFFFB74D)),
                    _buildMacroGauge('Fat', controller.totalFat, const Color(0xFF64B5F6)),
                    _buildMacroGauge('Fiber', controller.totalFiber, const Color(0xFF4DB6AC)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Portion Customizer Form
          const Text('Serving Specifications', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Base weight text field
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: gramsInputController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) {
                            final g = double.tryParse(val);
                            if (g != null && g > 0) {
                              controller.setServingGrams(g);
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: 'grams',
                            suffixStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips Shortcuts
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildServingQuickChip(controller, gramsInputController, '½ portion', food.defaultServingGrams / 2),
                    _buildServingQuickChip(controller, gramsInputController, '1 portion', food.defaultServingGrams),
                    _buildServingQuickChip(controller, gramsInputController, '1.5 portions', food.defaultServingGrams * 1.5),
                    _buildServingQuickChip(controller, gramsInputController, '2 portions', food.defaultServingGrams * 2),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 20),
                // Serving count multiplier picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number of Servings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 20),
                            color: AppColors.primaryDark,
                            onPressed: controller.servings > 1 ? () => controller.setServings(controller.servings - 1) : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${controller.servings}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 20),
                            color: AppColors.primaryDark,
                            onPressed: () => controller.setServings(controller.servings + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Meal Diary Classifier Pills
          const Text('Select Meal Type', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          _buildMealSelector(controller),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await controller.logFood();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${food.name} successfully added to ${_capitalize(controller.selectedMealType)}!'),
                            backgroundColor: AppColors.primaryDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                        Navigator.pop(context); // Pop back to dashboard/diary page
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      shadowColor: AppColors.primaryDark.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Log ${controller.totalCalories.round()} kcal',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => controller.resetScanner(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('Scan again', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper macro visual gauges
  Widget _buildMacroGauge(String title, double grams, Color color) {
    return Column(
      children: [
        Text(
          '${grams.toStringAsFixed(1)}g',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500]),
        ),
        const SizedBox(height: 6),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (grams / 50).clamp(0.0, 1.0), // visual normalization
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Meal selector selector pills
  Widget _buildMealSelector(BarcodeScannerController controller) {
    final meals = [
      {'id': 'breakfast', 'label': 'Breakfast', 'icon': Icons.wb_twilight},
      {'id': 'lunch', 'label': 'Lunch', 'icon': Icons.wb_sunny},
      {'id': 'dinner', 'label': 'Dinner', 'icon': Icons.nights_stay},
      {'id': 'snack', 'label': 'Snack', 'icon': Icons.fastfood},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: meals.map((meal) {
        final isSelected = controller.selectedMealType == meal['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.setMealType(meal['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? null : Border.all(color: AppColors.border),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meal['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Portion quick chips selector
  Widget _buildServingQuickChip(
      BarcodeScannerController controller, TextEditingController textController, String label, double grams) {
    final isActive = (controller.servingGrams - grams).abs() < 1;
    return GestureDetector(
      onTap: () {
        controller.setServingGrams(grams);
        textController.text = grams.toInt().toString();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit': return '🍎';
      case 'grains':
      case 'bread': return '🌾';
      case 'protein':
      case 'meat': return '🍗';
      case 'dairy':
      case 'milk': return '🥛';
      case 'snacks':
      case 'snack': return '🍿';
      case 'beverages':
      case 'drink': return '🥤';
      default: return '🍽️';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildErrorCard(BarcodeScannerController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sentiment_dissatisfied_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Product Not Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.errorText!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('${AppRoutes.addFood}?mealType=${controller.selectedMealType}');
                  },
                  icon: const Icon(Icons.search, size: 16, color: Colors.white),
                  label: const Text('Search Manually', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.resetScanner();
                    _textController.clear();
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 16, color: AppColors.textPrimary),
                  label: const Text('Clear / Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Custom Painters & Scanning Animations
// ═══════════════════════════════════════════════════════════════

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Save layer to let BlendMode.clear clear the cutout locally
    canvas.saveLayer(rect, Paint());

    // Paint semi-transparent black overlay outside the viewport
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // Viewport window measurements
    final cutOutWidth = size.width * 0.75;
    final cutOutHeight = size.width * 0.50; // widescreen-like barcode window
    final left = (size.width - cutOutWidth) / 2;
    final top = (size.height - cutOutHeight) / 2.3; // shifted slightly up
    final cutoutRect = Rect.fromLTWH(left, top, cutOutWidth, cutOutHeight);
    final cutoutRRect = RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20));

    // Clear the cutout area
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cutoutRRect, clearPaint);

    canvas.restore();

    // Mask the outer corners of the viewport container (radius 24) using BlendMode.clear
    // to avoid GPU-level clipping bugs (which cause green tint).
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFFF9F9FB)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // White highlight framing stroke paint (no green border)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const cornerLength = 24.0;

    // Top-Left corner border highlight
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.top + cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.top)
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.top),
      borderPaint,
    );

    // Top-Right corner border highlight
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.top)
        ..lineTo(cutoutRect.right, cutoutRect.top)
        ..lineTo(cutoutRect.right, cutoutRect.top + cornerLength),
      borderPaint,
    );

    // Bottom-Left corner border highlight
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.bottom - cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.bottom)
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.bottom),
      borderPaint,
    );

    // Bottom-Right corner border highlight
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.bottom)
        ..lineTo(cutoutRect.right, cutoutRect.bottom)
        ..lineTo(cutoutRect.right, cutoutRect.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanningLaserLine extends StatefulWidget {
  const ScanningLaserLine({super.key});

  @override
  State<ScanningLaserLine> createState() => _ScanningLaserLineState();
}

class _ScanningLaserLineState extends State<ScanningLaserLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            final yOffset = _controller.value * maxHeight;
            
            return Stack(
              children: [
                Positioned(
                  top: yOffset,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
