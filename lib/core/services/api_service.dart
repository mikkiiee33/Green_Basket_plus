import 'dart:convert';
import 'package:http/http.dart' as http;



class ApiConfig {
  static const String baseUrl = 'https://9z8drqu2hk.execute-api.ap-south-1.amazonaws.com';

  static const String register       = '$baseUrl/auth/register';
  static const String login          = '$baseUrl/auth/login';
  static const String refreshToken   = '$baseUrl/auth/refresh';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String profile        = '$baseUrl/profile';
  static const String medications    = '$baseUrl/medications';
  static const String habits         = '$baseUrl/habits';
  static const String habitsScore    = '$baseUrl/habits/score';
  static const String checkups       = '$baseUrl/checkups';
  static const String greenbotChat   = '$baseUrl/greenbot/chat';
}

class ApiResponse<T> {
  final bool    success;
  final String  message;
  final T?      data;
  final int     statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401;
}



class ApiService {
  static String? _accessToken;
  static String? _refreshTokenValue;

  static void setTokens(String accessToken, String refreshToken) {
    _accessToken       = accessToken;
    _refreshTokenValue = refreshToken;
  }

  static void clearTokens() {
    _accessToken       = null;
    _refreshTokenValue = null;
  }

  static Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> get _authHeaders => {
    'Content-Type':  'application/json',
    'Authorization': 'Bearer ${_accessToken ?? ''}',
  };

  static Future<ApiResponse<Map<String, dynamic>>> _request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    bool isRetry      = false,
  }) async {
    try {
      final headers = requiresAuth ? _authHeaders : _publicHeaders;
      final bodyStr = body != null ? jsonEncode(body) : null;

      http.Response response;
      final uri = Uri.parse(url);

      switch (method.toUpperCase()) {
        case 'GET':    response = await http.get(uri, headers: headers);    break;
        case 'POST':   response = await http.post(uri, headers: headers, body: bodyStr);   break;
        case 'PUT':    response = await http.put(uri, headers: headers, body: bodyStr);    break;
        case 'PATCH':  response = await http.patch(uri, headers: headers, body: bodyStr);  break;
        case 'DELETE': response = await http.delete(uri, headers: headers); break;
        default: throw Exception('Unknown method: $method');
      }

      if (response.statusCode == 401 && !isRetry && _refreshTokenValue != null) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          return _request(method: method, url: url, body: body,
              requiresAuth: requiresAuth, isRetry: true);
        }
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(
        success:    decoded['success'] == true,
        message:    decoded['message'] as String? ?? '',
        data:       decoded['data']    as Map<String, dynamic>?,
        statusCode: response.statusCode,
      );

    } catch (e) {
      return ApiResponse(
        success:    false,
        message:    'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  static Future<bool> _tryRefresh() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.refreshToken),
        headers: _publicHeaders,
        body: jsonEncode({'refreshToken': _refreshTokenValue}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _accessToken = decoded['data']['accessToken'];
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // AUTH
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
  }) => _request(
        method: 'POST', url: ApiConfig.register,
        body: {'name': name, 'email': email, 'password': password},
        requiresAuth: false,
      );

  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final res = await _request(
      method: 'POST', url: ApiConfig.login,
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );
    if (res.success && res.data != null) {
      final tokens = res.data!['tokens'] as Map<String, dynamic>?;
      if (tokens != null) {
        setTokens(tokens['accessToken'], tokens['refreshToken']);
      }
    }
    return res;
  }

  // PROFILE
  static Future<ApiResponse<Map<String, dynamic>>> getProfile() =>
      _request(method: 'GET', url: ApiConfig.profile);

  static Future<ApiResponse<Map<String, dynamic>>> saveProfile(
      Map<String, dynamic> data) =>
      _request(method: 'PUT', url: ApiConfig.profile, body: data);

  // MEDICATIONS
  static Future<ApiResponse<Map<String, dynamic>>> getMedications() =>
      _request(method: 'GET', url: ApiConfig.medications);

  static Future<ApiResponse<Map<String, dynamic>>> addMedication(
      Map<String, dynamic> data) =>
      _request(method: 'POST', url: ApiConfig.medications, body: data);

  static Future<ApiResponse<Map<String, dynamic>>> updateMedication(
      String id, Map<String, dynamic> data) =>
      _request(method: 'PUT', url: '${ApiConfig.medications}/$id', body: data);

  static Future<ApiResponse<Map<String, dynamic>>> deleteMedication(String id) =>
      _request(method: 'DELETE', url: '${ApiConfig.medications}/$id');

  static Future<ApiResponse<Map<String, dynamic>>> markMedication(
      String id, String status) =>
      _request(method: 'PATCH',
               url: '${ApiConfig.medications}/$id/status',
               body: {'status': status});

  // HABITS
  static Future<ApiResponse<Map<String, dynamic>>> getHabits({String? date}) =>
      _request(method: 'GET',
               url: date != null ? '${ApiConfig.habits}?date=$date' : ApiConfig.habits);

  static Future<ApiResponse<Map<String, dynamic>>> updateHabits({
    required List<String> completedIds,
    required int totalHabits,
    String? dateKey,
  }) => _request(method: 'PUT', url: ApiConfig.habits, body: {
        'completedHabitIds': completedIds,
        'totalHabits':       totalHabits,
        if (dateKey != null) 'dateKey': dateKey,
      });

  static Future<ApiResponse<Map<String, dynamic>>> getHealthScore() =>
      _request(method: 'GET', url: ApiConfig.habitsScore);

  // CHECKUPS
  static Future<ApiResponse<Map<String, dynamic>>> getCheckups() =>
      _request(method: 'GET', url: ApiConfig.checkups);

  static Future<ApiResponse<Map<String, dynamic>>> markCheckupDone(String id) =>
      _request(method: 'PATCH', url: '${ApiConfig.checkups}/$id/done');

  // GREENBOT
  static Future<ApiResponse<Map<String, dynamic>>> chatWithGreenBot({
    required String message,
    List<Map<String, String>>? history,
  }) => _request(
        method: 'POST',
        url:    ApiConfig.greenbotChat,
        body: {
          'message': message,
          if (history != null) 'history': history,
        },
      );
}
