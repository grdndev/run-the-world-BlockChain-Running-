import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette (from mockups)
  static const Color skyBlueLight = Color(0xFF87CEEB);
  static const Color skyBlueDark = Color(0xFF4AA8D8);
  static const Color navyCard = Color(0xFF2D3A5C);
  static const Color navyCardBorder = Color(0xFF4A5A80);
  static const Color navyDark = Color(0xFF1A2744);

  // Accent colors
  static const Color gold = Color(0xFFFFD700);
  static const Color goldenYellow = Color(0xFFFFC107);
  static const Color orange = Color(0xFFFF8C00);
  static const Color orangeButton = Color(0xFFFF9800);
  static const Color orangeButtonDark = Color(0xFFE67E00);

  // Input fields
  static const Color inputYellow = Color(0xFFFFE082);
  static const Color inputYellowDark = Color(0xFFFFCA28);

  // Ranking
  static const Color rankGold = Color(0xFFFFD54F);
  static const Color rankSilver = Color(0xFFCFD8DC);
  static const Color rankBronze = Color(0xFFBCAAA4);
  static const Color rankGreen = Color(0xFF66BB6A);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A2744);
  static const Color textGold = Color(0xFFFFD700);
  static const Color textOrange = Color(0xFFFF8C00);
  static const Color textHint = Color(0xFFD4883C);

  // Bottom nav
  static const Color bottomNavBlue = Color(0xFF1A3A8A);
  static const Color bottomNavActive = Color(0xFFFF8C00);

  // Map
  static const Color hexBorder = Color(0xFFB0BEC5);
  static const Color hexActive = Color(0xFFFFE0B2);
  static const Color traceYellow = Color(0xFFFFD54F);
  static const Color landAvailable = Color(0xFF4CAF50);

  // Gradients
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF87CEEB), Color(0xFF4AA8D8)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF9800), Color(0xFFE67E00)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D3A5C), Color(0xFF1A2744)],
  );
}
