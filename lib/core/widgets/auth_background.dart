import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CurvePainter(isDark: isDark),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final bool isDark;
  _CurvePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = isDark ? AppColors.primaryBlueDark : AppColors.primaryBlueLight
      ..style = PaintingStyle.fill;

    final orangePaint = Paint()
      ..color = isDark ? AppColors.primaryOrangeDark : AppColors.primaryOrangeLight
      ..style = PaintingStyle.fill;

    // Top Blue Curve
    final topPath = Path();
    topPath.lineTo(0, size.height * 0.15);
    topPath.quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width, size.height * 0.1);
    topPath.lineTo(size.width, 0);
    topPath.close();
    canvas.drawPath(topPath, bluePaint);

    // Bottom Orange Curve
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height);
    bottomPath.lineTo(0, size.height * 0.95);
    bottomPath.quadraticBezierTo(size.width * 0.4, size.height * 0.88, size.width, size.height * 0.85);
    bottomPath.lineTo(size.width, size.height);
    bottomPath.close();
    canvas.drawPath(bottomPath, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}