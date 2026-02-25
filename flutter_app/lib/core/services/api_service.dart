import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  Dio get dio => _dio;

  // ==================== TOKEN MANAGEMENT ====================

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Try refreshing the token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request
        final opts = error.requestOptions;
        final token = await _storage.read(key: _accessTokenKey);
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(error);
        }
      }
    }
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(baseUrl: AppConstants.apiBaseUrl),
      ).post('/auth/refresh', data: {'refreshToken': refreshToken});

      if (response.statusCode == 200) {
        await saveTokens(
          response.data['accessToken'],
          response.data['refreshToken'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }

  // ==================== AUTH ENDPOINTS ====================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'username': username},
    );
    final data = response.data;
    await saveTokens(data['accessToken'], data['refreshToken']);
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    await saveTokens(data['accessToken'], data['refreshToken']);
    return data;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> renewId() async {
    await _dio.post('/auth/renew-id');
  }

  Future<void> logout() async {
    await clearTokens();
  }

  // ==================== PLAYER ENDPOINTS ====================

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get('/players/me');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? nationality,
  }) async {
    final response = await _dio.patch(
      '/players/me',
      data: {
        if (username != null) 'username': username,
        if (nationality != null) 'nationality': nationality,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> upgradeGrade() async {
    final response = await _dio.post('/players/me/upgrade-grade');
    return response.data;
  }

  // ==================== LEAGUE ENDPOINTS ====================

  Future<Map<String, dynamic>> getLeagueRanking({int? leagueNumber}) async {
    final response = await _dio.get(
      '/leagues/ranking',
      queryParameters: {if (leagueNumber != null) 'leagueNumber': leagueNumber},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getLeagueInfo(int leagueNumber) async {
    final response = await _dio.get('/leagues/$leagueNumber');
    return response.data;
  }

  Future<Map<String, dynamic>> getGlobalTop({int limit = 50}) async {
    final response = await _dio.get(
      '/leagues/global/top',
      queryParameters: {'limit': limit},
    );
    return response.data;
  }

  // ==================== RUN ENDPOINTS ====================

  Future<Map<String, dynamic>> startRun({double? lat, double? lng}) async {
    final response = await _dio.post(
      '/runs/start',
      data: {'lat': lat, 'lng': lng},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateRunTrace(
    String runId,
    List<Map<String, dynamic>> points,
  ) async {
    final response = await _dio.patch(
      '/runs/$runId/trace',
      data: {'points': points},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> endRun(
    String runId, {
    List<String> h3Indexes = const [],
  }) async {
    final response = await _dio.post(
      '/runs/$runId/end',
      data: {'h3Indexes': h3Indexes},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getActiveRun() async {
    final response = await _dio.get('/runs/active');
    return response.data;
  }

  Future<Map<String, dynamic>> getRunHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/runs/history',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> activateBoost({String type = 'FREE'}) async {
    final response = await _dio.post('/runs/boost', data: {'type': type});
    return response.data;
  }

  // ==================== LAND ENDPOINTS ====================

  Future<Map<String, dynamic>> exploreLand({
    required String h3Index,
    required double lat,
    required double lng,
    String? city,
    String? country,
  }) async {
    final response = await _dio.post(
      '/lands/explore',
      data: {
        'h3Index': h3Index,
        'lat': lat,
        'lng': lng,
        'city': city,
        'country': country,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getNearbyLands({
    required double lat,
    required double lng,
    double radius = 0.01,
  }) async {
    final response = await _dio.get(
      '/lands/nearby',
      queryParameters: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> rentLand(String landId) async {
    final response = await _dio.post('/lands/$landId/rent');
    return response.data;
  }

  Future<Map<String, dynamic>> buyLand(String landId) async {
    final response = await _dio.post('/lands/$landId/buy');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyLands() async {
    final response = await _dio.get('/lands/mine');
    return response.data;
  }

  Future<Map<String, dynamic>> getLandDetails(String landId) async {
    final response = await _dio.get('/lands/$landId');
    return response.data;
  }
}
