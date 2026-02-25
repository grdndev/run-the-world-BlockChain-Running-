import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';

// ==================== PLAYER PROVIDER ====================

class PlayerState {
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  const PlayerState({this.profile, this.isLoading = false, this.error});

  PlayerState copyWith({
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
  }) {
    return PlayerState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Convenience getters
  String get username => profile?['username'] ?? 'Joueur';
  String get grade => profile?['grade'] ?? 'STARTER';
  int get rpcBalance => profile?['rpcBalance'] ?? 0;
  double get oziBalance => (profile?['oziBalance'] ?? 0).toDouble();
  int get totalPts => profile?['totalPts'] ?? 0;
  double get totalKm => (profile?['totalKm'] ?? 0).toDouble();
  int get leagueNumber => profile?['leagueNumber'] ?? 1;
  int get leagueRank => profile?['leagueRank'] ?? 0;
  String get nationality => profile?['nationality'] ?? '';
  bool get idActive => profile?['idActive'] ?? false;
}

class PlayerNotifier extends Notifier<PlayerState> {
  final ApiService _api = ApiService();

  @override
  PlayerState build() => const PlayerState();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getMyProfile();
      state = PlayerState(profile: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur de chargement');
    }
  }

  Future<bool> updateProfile({String? username, String? nationality}) async {
    try {
      final data = await _api.updateProfile(
        username: username,
        nationality: nationality,
      );
      final merged = <String, dynamic>{};
      if (state.profile != null) merged.addAll(state.profile!);
      merged.addAll(data);
      state = state.copyWith(profile: merged);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> upgradeGrade() async {
    try {
      await _api.upgradeGrade();
      await loadProfile();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);

// ==================== LEAGUE/RANKING PROVIDER ====================

class RankingState {
  final List<Map<String, dynamic>> players;
  final int myRank;
  final int leagueNumber;
  final bool isLoading;

  const RankingState({
    this.players = const [],
    this.myRank = 0,
    this.leagueNumber = 1,
    this.isLoading = false,
  });

  RankingState copyWith({
    List<Map<String, dynamic>>? players,
    int? myRank,
    int? leagueNumber,
    bool? isLoading,
  }) {
    return RankingState(
      players: players ?? this.players,
      myRank: myRank ?? this.myRank,
      leagueNumber: leagueNumber ?? this.leagueNumber,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RankingNotifier extends Notifier<RankingState> {
  final ApiService _api = ApiService();

  @override
  RankingState build() => const RankingState();

  Future<void> loadRanking({int? leagueNumber}) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getLeagueRanking(leagueNumber: leagueNumber);
      state = RankingState(
        players: List<Map<String, dynamic>>.from(data['players'] ?? []),
        myRank: data['myRank'] ?? 0,
        leagueNumber: data['leagueNumber'] ?? 1,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final rankingProvider = NotifierProvider<RankingNotifier, RankingState>(
  RankingNotifier.new,
);

// ==================== RUN PROVIDER ====================

class RunState {
  final bool isRunning;
  final String? activeRunId;
  final double currentDistance;
  final List<Map<String, dynamic>> runHistory;
  final bool isLoading;

  const RunState({
    this.isRunning = false,
    this.activeRunId,
    this.currentDistance = 0,
    this.runHistory = const [],
    this.isLoading = false,
  });

  RunState copyWith({
    bool? isRunning,
    String? activeRunId,
    double? currentDistance,
    List<Map<String, dynamic>>? runHistory,
    bool? isLoading,
  }) {
    return RunState(
      isRunning: isRunning ?? this.isRunning,
      activeRunId: activeRunId ?? this.activeRunId,
      currentDistance: currentDistance ?? this.currentDistance,
      runHistory: runHistory ?? this.runHistory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RunNotifier extends Notifier<RunState> {
  final ApiService _api = ApiService();

  @override
  RunState build() => const RunState();

  Future<void> checkActiveRun() async {
    try {
      final data = await _api.getActiveRun();
      if (data['active'] == true) {
        state = state.copyWith(
          isRunning: true,
          activeRunId: data['runId'],
          currentDistance: (data['currentDistance'] ?? 0).toDouble(),
        );
      }
    } catch (_) {}
  }

  Future<bool> startRun({double? lat, double? lng}) async {
    try {
      final data = await _api.startRun(lat: lat, lng: lng);
      state = state.copyWith(
        isRunning: true,
        activeRunId: data['runId'],
        currentDistance: 0,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> endRun({
    List<String> h3Indexes = const [],
  }) async {
    if (state.activeRunId == null) return null;
    try {
      final data = await _api.endRun(state.activeRunId!, h3Indexes: h3Indexes);
      state = const RunState();
      return data['summary'];
    } catch (_) {
      return null;
    }
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getRunHistory();
      state = state.copyWith(
        runHistory: List<Map<String, dynamic>>.from(data['runs'] ?? []),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final runProvider = NotifierProvider<RunNotifier, RunState>(RunNotifier.new);

// ==================== LAND PROVIDER ====================

class LandState {
  final List<Map<String, dynamic>> nearbyLands;
  final List<Map<String, dynamic>> rentedLands;
  final List<Map<String, dynamic>> ownedLands;
  final List<Map<String, dynamic>> exploredLands;
  final bool isLoading;

  const LandState({
    this.nearbyLands = const [],
    this.rentedLands = const [],
    this.ownedLands = const [],
    this.exploredLands = const [],
    this.isLoading = false,
  });

  LandState copyWith({
    List<Map<String, dynamic>>? nearbyLands,
    List<Map<String, dynamic>>? rentedLands,
    List<Map<String, dynamic>>? ownedLands,
    List<Map<String, dynamic>>? exploredLands,
    bool? isLoading,
  }) {
    return LandState(
      nearbyLands: nearbyLands ?? this.nearbyLands,
      rentedLands: rentedLands ?? this.rentedLands,
      ownedLands: ownedLands ?? this.ownedLands,
      exploredLands: exploredLands ?? this.exploredLands,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LandNotifier extends Notifier<LandState> {
  final ApiService _api = ApiService();

  @override
  LandState build() => const LandState();

  Future<void> loadMyLands() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getMyLands();
      state = LandState(
        rentedLands: List<Map<String, dynamic>>.from(data['rented'] ?? []),
        ownedLands: List<Map<String, dynamic>>.from(data['owned'] ?? []),
        exploredLands: List<Map<String, dynamic>>.from(data['explored'] ?? []),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadNearby(double lat, double lng) async {
    try {
      final data = await _api.getNearbyLands(lat: lat, lng: lng);
      state = state.copyWith(
        nearbyLands: List<Map<String, dynamic>>.from(data['lands'] ?? []),
      );
    } catch (_) {}
  }

  Future<bool> rentLand(String landId) async {
    try {
      await _api.rentLand(landId);
      await loadMyLands();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> buyLand(String landId) async {
    try {
      await _api.buyLand(landId);
      await loadMyLands();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final landProvider = NotifierProvider<LandNotifier, LandState>(
  LandNotifier.new,
);
