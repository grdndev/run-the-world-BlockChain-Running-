import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Background with sky gradient + landscape illustration (matching mockups)
class SkyBackground extends StatelessWidget {
  final Widget child;
  final bool showLandscape;

  const SkyBackground({
    super.key,
    required this.child,
    this.showLandscape = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Stack(
        children: [
          // Landscape at the bottom
          if (showLandscape)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: _LandscapePainter(),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Green hills
    final hillPaint = Paint()..color = const Color(0xFF4CAF50);
    final hillPath = Path();
    hillPath.moveTo(0, size.height * 0.6);
    hillPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.5,
    );
    hillPath.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.8,
      size.width * 0.8,
      size.height * 0.3,
    );
    hillPath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.1,
      size.width,
      size.height * 0.4,
    );
    hillPath.lineTo(size.width, size.height);
    hillPath.lineTo(0, size.height);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // Lighter green foreground hills
    final lightHillPaint = Paint()..color = const Color(0xFF66BB6A);
    final lightHillPath = Path();
    lightHillPath.moveTo(0, size.height * 0.8);
    lightHillPath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.7,
    );
    lightHillPath.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.9,
      size.width,
      size.height * 0.6,
    );
    lightHillPath.lineTo(size.width, size.height);
    lightHillPath.lineTo(0, size.height);
    lightHillPath.close();
    canvas.drawPath(lightHillPath, lightHillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
