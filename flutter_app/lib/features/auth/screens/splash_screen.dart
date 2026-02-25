import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sky_background.dart';
import '../../../shared/widgets/rtw_logo.dart';
import '../../../shared/widgets/rtw_button.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              const RtwLogo(fontSize: 56),
              const SizedBox(height: 40),
              // Dog mascot placeholder (cartoon circle)
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 100,
                  color: AppColors.goldenYellow,
                ),
              ),
              const Spacer(flex: 3),
              // START button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: RtwButton(
                  text: 'START',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  ),
                  onPressed: () => context.go('/login'),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
