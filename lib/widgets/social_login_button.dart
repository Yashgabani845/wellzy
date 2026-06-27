import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class SocialLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;

    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableTap = widget.isLoading;

    return GestureDetector(
      onTapDown: (_) => disableTap ? null : _controller.reverse(),
      onTapUp: (_) => disableTap ? null : _controller.forward(),
      onTapCancel: () => disableTap ? null : _controller.forward(),
      onTap: disableTap ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppConstants.borderRadiusButton,
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.isLoading
                ? [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Connecting to Google...',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ]
                : [
                    CustomPaint(
                      size: const Size(22, 22),
                      painter: GoogleLogoPainter(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Scale canvas to drawing coordinates base (24x24)
    canvas.save();
    canvas.scale(w / 24.0, h / 24.0);

    // Red segment
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path redPath = Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.06)
      ..lineTo(5.84, 9.9)
      ..cubicTo(6.71, 7.3, 9.14, 5.38, 12.0, 5.38)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow segment
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path yellowPath = Path()
      ..moveTo(5.84, 14.1)
      ..cubicTo(5.62, 13.44, 5.49, 12.73, 5.49, 12.0)
      ..cubicTo(5.49, 11.27, 5.62, 10.56, 5.84, 9.9)
      ..lineTo(2.18, 7.06)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.94)
      ..lineTo(5.84, 14.1)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green segment
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path greenPath = Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)
      ..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Blue segment
    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path bluePath = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.26)
      ..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(19.28, 20.34)
      ..cubicTo(21.37, 18.4, 22.56, 15.6, 22.56, 12.25)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
