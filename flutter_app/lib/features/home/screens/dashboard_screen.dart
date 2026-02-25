import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildPlayerCard(),
              const SizedBox(height: 16),
              _buildWalletGrid(),
              const SizedBox(height: 16),
              _buildPerformanceSummary(),
              const SizedBox(height: 16),
              _buildLeagueDashboard(),
              const SizedBox(height: 16),
              _buildTerritoryPreview(),
              const SizedBox(height: 16),
              _buildGradeProgression(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour 👋',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Ratlamarche',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navyCard.withValues(alpha: 0.6),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: AppColors.goldenYellow,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard() {
    return GlassCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputYellow,
              border: Border.all(color: AppColors.goldenYellow, width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.navyDark,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Ratlamarche',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldenYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'STARTER',
                        style: TextStyle(
                          color: AppColors.navyDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🇫🇷', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.shield,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID OK • 8j',
                          style: TextStyle(
                            color: Colors.green.shade300,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _WalletMiniCard(
              icon: Icons.monetization_on_rounded,
              iconColor: AppColors.goldenYellow,
              label: 'RPC',
              value: '8,000',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _WalletMiniCard(
              icon: Icons.diamond_rounded,
              iconColor: const Color(0xFF7C4DFF),
              label: 'OZI',
              value: '0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              iconColor: AppColors.orange,
              label: 'PTS',
              value: '854',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.directions_run_rounded,
              iconColor: const Color(0xFF42A5F5),
              label: 'KM',
              value: '154.2',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueDashboard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ma League',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.orangeButtonDark,
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  'League 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rank
          Row(
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                color: AppColors.goldenYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Rang Global · ',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Text(
                '#246',
                style: TextStyle(
                  color: AppColors.goldenYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 10,
              backgroundColor: AppColors.navyDark,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.goldenYellow,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Maintien',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: Colors.green.shade400,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'En bonne voie',
                    style: TextStyle(
                      color: Colors.green.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryPreview() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conquête Territoriale',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // Hex grid preview
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.navyCardBorder, width: 1),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 18,
              itemBuilder: (context, i) {
                final isActive = i == 8;
                return Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.orange.withValues(alpha: 0.6)
                        : AppColors.navyCardBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive
                          ? AppColors.orange
                          : AppColors.navyCardBorder.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Land info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navyDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldenYellow.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.goldenYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.goldenYellow,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAND #2453 DISPONIBLE',
                        style: TextStyle(
                          color: AppColors.goldenYellow,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Zone Paris / Europe',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Explorer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeProgression() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Prochain Grade',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navyDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.navyCardBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF42A5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'DÉBUTANT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _GradeRequirement(
                  label: 'Périodes',
                  current: '1',
                  required_: '2',
                ),
                const SizedBox(height: 6),
                _GradeRequirement(
                  label: 'RPC',
                  current: '8,000',
                  required_: '15,000',
                ),
                const SizedBox(height: 6),
                _GradeRequirement(
                  label: 'PTS cumulés',
                  current: '854',
                  required_: '500',
                  isMet: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _WalletMiniCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyCardBorder.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyCardBorder.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeRequirement extends StatelessWidget {
  final String label;
  final String current;
  final String required_;
  final bool isMet;

  const _GradeRequirement({
    required this.label,
    required this.current,
    required this.required_,
    this.isMet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          color: isMet ? const Color(0xFF4CAF50) : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const Spacer(),
        Text(
          '$current / $required_',
          style: TextStyle(
            color: isMet ? const Color(0xFF4CAF50) : AppColors.goldenYellow,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
