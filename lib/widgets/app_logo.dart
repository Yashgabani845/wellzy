import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: LogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'Wellzy',
            style: AppTextStyles.largeHeading.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          Text(
            'AI HEALTH & NUTRITION',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Linear gradient for W
    final Paint wPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Linear gradient for Leaf
    final Paint leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF6BCB77)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // White details/vein paint
    final Paint veinPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Path for 'W' - stylized, premium
    // Left diagonal stem, middle joint, right diagonal stem
    final Path wPath = Path();
    wPath.moveTo(w * 0.28, h * 0.35); // Start of main stem
    wPath.lineTo(w * 0.40, h * 0.85); // Left bottom
    wPath.lineTo(w * 0.53, h * 0.50); // Middle point
    wPath.lineTo(w * 0.65, h * 0.85); // Right bottom
    wPath.lineTo(w * 0.82, h * 0.35); // Right top
    wPath.lineTo(w * 0.72, h * 0.35); // Thickness right top
    wPath.lineTo(w * 0.59, h * 0.75); // Inner right bottom
    wPath.lineTo(w * 0.47, h * 0.45); // Inner middle point
    wPath.lineTo(w * 0.35, h * 0.75); // Inner left bottom
    wPath.close();

    canvas.drawPath(wPath, wPaint);

    // Path for leaf overlapping top-left stem
    final Path leafPath = Path();
    leafPath.moveTo(w * 0.12, h * 0.22); // Leaf tip
    // Top curve of leaf
    leafPath.quadraticBezierTo(
      w * 0.35, h * 0.12, // Control point
      w * 0.55, h * 0.42, // End point
    );
    // Bottom curve of leaf
    leafPath.quadraticBezierTo(
      w * 0.25, h * 0.58, // Control point
      w * 0.12, h * 0.22, // Back to tip
    );
    leafPath.close();

    canvas.drawPath(leafPath, leafPaint);

    // Leaf center vein
    final Path veinPath = Path();
    veinPath.moveTo(w * 0.14, h * 0.24);
    veinPath.quadraticBezierTo(
      w * 0.32, h * 0.32,
      w * 0.52, h * 0.40,
    );
    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
