import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showLandPopup = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map background (placeholder - will use google_maps_flutter later)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE8F0F8),
          child: CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: _HexGridPainter(),
          ),
        ),
        // GPS trace (yellow path)
        CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          painter: _GpsTracePainter(),
        ),
        // Active hexagons along the trace
        CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          painter: _ActiveHexPainter(),
        ),
        // Current position indicator
        Positioned(
          right: 60,
          top: MediaQuery.of(context).size.height * 0.38,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF42E5F5),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF42E5F5).withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ),
        // LAND disponible popup
        if (_showLandPopup)
          Positioned(
            right: 30,
            top: MediaQuery.of(context).size.height * 0.15,
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to land details
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'LAND\ndisponible',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Revendiquer\ncette LAND',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Triangle pointer
                    CustomPaint(
                      size: const Size(20, 10),
                      painter: _TrianglePainter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Fake street labels for realism
        ..._buildStreetLabels(context),
      ],
    );
  }

  List<Widget> _buildStreetLabels(BuildContext context) {
    final labels = [
      {'text': '86th Street', 'left': 20.0, 'top': 200.0, 'angle': 0.0},
      {'text': '18th Avenue', 'left': 100.0, 'top': 300.0, 'angle': -1.2},
      {'text': '4th Avenue', 'left': 250.0, 'top': 400.0, 'angle': -1.0},
      {'text': '10th Av', 'left': 200.0, 'top': 600.0, 'angle': 0.0},
    ];

    return labels.map((l) {
      return Positioned(
        left: l['left'] as double,
        top: l['top'] as double,
        child: Transform.rotate(
          angle: l['angle'] as double,
          child: Text(
            l['text'] as String,
            style: TextStyle(
              color: Colors.blueGrey.shade300,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCD6E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const hexRadius = 22.0;
    final hexWidth = hexRadius * 2;
    final hexHeight = sqrt(3) * hexRadius;

    for (double y = -hexHeight; y < size.height + hexHeight; y += hexHeight) {
      for (
        double x = -hexWidth;
        x < size.width + hexWidth;
        x += hexWidth * 1.5
      ) {
        _drawHex(canvas, Offset(x, y), hexRadius, paint);
        _drawHex(
          canvas,
          Offset(x + hexWidth * 0.75, y + hexHeight * 0.5),
          hexRadius,
          paint,
        );
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * pi / 180;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GpsTracePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.traceYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Simulate a GPS trace going from bottom to top
    path.moveTo(size.width * 0.45, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.42,
      size.height * 0.7,
      size.width * 0.44,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.46,
      size.height * 0.4,
      size.width * 0.55,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.25,
      size.width * 0.58,
      size.height * 0.18,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActiveHexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.hexActive.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.traceYellow.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const hexRadius = 22.0;

    // Active hexagons along the trace path
    final activePositions = [
      Offset(size.width * 0.45, size.height * 0.82),
      Offset(size.width * 0.44, size.height * 0.76),
      Offset(size.width * 0.43, size.height * 0.70),
      Offset(size.width * 0.43, size.height * 0.64),
      Offset(size.width * 0.44, size.height * 0.58),
      Offset(size.width * 0.45, size.height * 0.52),
      Offset(size.width * 0.47, size.height * 0.46),
      Offset(size.width * 0.50, size.height * 0.40),
      Offset(size.width * 0.53, size.height * 0.34),
      Offset(size.width * 0.55, size.height * 0.28),
      Offset(size.width * 0.57, size.height * 0.22),
      Offset(size.width * 0.58, size.height * 0.18),
    ];

    for (final pos in activePositions) {
      _drawHex(canvas, pos, hexRadius, paint);
      _drawHex(canvas, pos, hexRadius, borderPaint);
    }
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * pi / 180;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFF9E6);
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
