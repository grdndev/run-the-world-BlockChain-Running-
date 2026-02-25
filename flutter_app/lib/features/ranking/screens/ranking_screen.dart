import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 1; // League selected by default

  final List<Map<String, dynamic>> _rankings = [
    {'rank': 1, 'name': 'Ratlamarche', 'pts': 11801, 'verified': true},
    {'rank': 2, 'name': 'Mc Gregor', 'pts': 11801, 'verified': false},
    {'rank': 3, 'name': 'Pimoustic', 'pts': 11801, 'verified': false},
    {'rank': 4, 'name': 'Cryptosurfer', 'pts': 11801, 'verified': false},
    {'rank': 5, 'name': 'HeroineIsm', 'pts': 11801, 'verified': false},
    {'rank': 6, 'name': 'Oxonomy', 'pts': 11801, 'verified': false},
    {'rank': 7, 'name': 'RiseUp', 'pts': 11801, 'verified': false},
    {'rank': 8, 'name': 'RunBeast', 'pts': 10503, 'verified': false},
    {'rank': 9, 'name': 'NightRunner', 'pts': 9800, 'verified': false},
    {'rank': 10, 'name': 'SpeedKing', 'pts': 9200, 'verified': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3D5BA9), Color(0xFF2D4A8C), Color(0xFF1A3570)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Title
            _buildTitle(),
            const SizedBox(height: 16),
            // Tabs
            _buildTabs(),
            const SizedBox(height: 16),
            // League badge
            _buildLeagueBadge(),
            const SizedBox(height: 16),
            // Rankings list
            Expanded(child: _buildRankingsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outline text
        Text(
          'Classement',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = const Color(0xFF1A2744),
          ),
        ),
        // Fill text
        const Text(
          'Classement',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: AppColors.goldenYellow,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['Racing', 'League', 'Team'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF455A8C).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldenYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF455A8C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLeagueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFF8E0000)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldenYellow, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'League 3',
        style: TextStyle(
          color: AppColors.goldenYellow,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildRankingsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _rankings.length,
      itemBuilder: (context, index) {
        final player = _rankings[index];
        return _RankingCard(
          rank: player['rank'],
          name: player['name'],
          pts: player['pts'],
          isVerified: player['verified'],
        );
      },
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  final String name;
  final int pts;
  final bool isVerified;

  const _RankingCard({
    required this.rank,
    required this.name,
    required this.pts,
    required this.isVerified,
  });

  Color get _backgroundColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD54F); // Gold
      case 2:
        return const Color(0xFFCFD8DC); // Silver
      case 3:
        return const Color(0xFFBCAAA4); // Bronze
      case 6:
        return const Color(0xFF66BB6A); // Green highlight
      default:
        return const Color(0xFFE0E0E0); // Normal grey
    }
  }

  Color get _textColor {
    if (rank <= 3 || rank == 6) return const Color(0xFF1A2744);
    return const Color(0xFF1A2744);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number / medal
          SizedBox(
            width: 36,
            child: rank <= 3
                ? _buildMedal()
                : Text(
                    '$rank',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          // Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF5DADE2).withValues(alpha: 0.3),
              border: Border.all(
                color: const Color(0xFF5DADE2).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person,
              color: _textColor.withValues(alpha: 0.5),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF1565C0),
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
          // Points
          Text(
            '$pts',
            style: TextStyle(
              color: rank == 6 ? Colors.white : AppColors.orange,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedal() {
    final colors = {
      1: [const Color(0xFFFFD700), const Color(0xFFFFA000)],
      2: [const Color(0xFFBDBDBD), const Color(0xFF9E9E9E)],
      3: [const Color(0xFFCD7F32), const Color(0xFFA0522D)],
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors[rank]!,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[rank]![0].withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
