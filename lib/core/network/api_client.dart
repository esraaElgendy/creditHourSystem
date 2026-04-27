import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_preferences.dart';
import 'api_constants.dart';

/// API Exception class for handling API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// API Client for making HTTP requests
class ApiClient {
  final AppPreferences _preferences;
  final http.Client _httpClient;

  ApiClient({AppPreferences? preferences, http.Client? httpClient})
      : _preferences = preferences ?? AppPreferences(),
        _httpClient = httpClient ?? http.Client();

  /// Get headers with optional auth token
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _preferences.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse(_getEndpoint(endpoint));
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_getEndpoint(endpoint));
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_getEndpoint(endpoint));
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .delete(uri, headers: headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_getEndpoint(endpoint));
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Helper to get full endpoint URL
  String _getEndpoint(String endpoint) {
    if (endpoint.startsWith('http')) return endpoint;
    return '${ApiConstants.baseUrl}$endpoint';
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {'data': body};
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', 401);
    } else if (response.statusCode == 400) {
      final message = body['message'] ?? body['errors']?.toString() ?? 'Bad request';
      throw ApiException(message, 400);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found', 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.', response.statusCode);
    } else {
      final message = body['message'] ?? 'Request failed';
      throw ApiException(message, response.statusCode);
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
