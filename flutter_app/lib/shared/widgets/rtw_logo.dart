import 'package:flutter/material.dart';

/// RTW logo with text styling matching mockups
class RtwLogo extends StatelessWidget {
  final double fontSize;

  const RtwLogo({super.key, this.fontSize = 48});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "RUN THE" text
        Text(
          'RUN THE',
          style: TextStyle(
            fontSize: fontSize * 0.65,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF3D4B8C),
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.5),
                offset: const Offset(0, -2),
                blurRadius: 0,
              ),
              const Shadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        // "WORLD" text - bigger, bolder
        Stack(
          children: [
            // Outline/shadow
            Text(
              'WORLD',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color(0xFF1A2744),
              ),
            ),
            // Fill
            Text(
              'WORLD',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF3D5BA9),
                letterSpacing: 4,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
