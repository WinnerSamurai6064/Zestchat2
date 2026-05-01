// lib/core/services/api_service.dart

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

// ─── Models ───────────────────────────────────────────────────────────────────
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;
  final String? traceId;

  const ApiResponse({
    this.data,
    this.error,
    required this.statusCode,
    this.traceId,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

// ─── API Service ──────────────────────────────────────────────────────────────
class ApiService {
  static const _baseUrl = 'https://api1.layzur.qzz.io';
  static const _timeout = Duration(seconds: 30);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ── Shared headers ──────────────────────────────────────────────────────────
  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ── Trace ID logging ────────────────────────────────────────────────────────
  void _logTrace(http.Response response, String endpoint) {
    final traceId = response.headers['x-trace-id'] ?? 'none';
    dev.log(
      '[ZestChat API] $endpoint → ${response.statusCode} | trace=$traceId',
      name: 'ApiService',
    );
  }

  // ── Generic POST ────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client
          .post(
            uri,
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      _logTrace(response, path);

      final traceId = response.headers['x-trace-id'];
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          data: decoded,
          statusCode: response.statusCode,
          traceId: traceId,
        );
      } else {
        return ApiResponse(
          error: decoded['message'] as String? ?? 'Unknown error',
          statusCode: response.statusCode,
          traceId: traceId,
        );
      }
    } on Exception catch (e) {
      dev.log('[ZestChat API] $path → Exception: $e', name: 'ApiService');
      return ApiResponse(
        error: e.toString(),
        statusCode: 0,
      );
    }
  }

  // ── Generic GET ─────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> _get(
    String path, {
    Map<String, String>? queryParams,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
    try {
      final response = await _client
          .get(uri, headers: _headers(token: token))
          .timeout(_timeout);

      _logTrace(response, path);

      final traceId = response.headers['x-trace-id'];
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          data: decoded,
          statusCode: response.statusCode,
          traceId: traceId,
        );
      } else {
        return ApiResponse(
          error: decoded['message'] as String? ?? 'Unknown error',
          statusCode: response.statusCode,
          traceId: traceId,
        );
      }
    } on Exception catch (e) {
      dev.log('[ZestChat API] $path → Exception: $e', name: 'ApiService');
      return ApiResponse(
        error: e.toString(),
        statusCode: 0,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/auth/register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String password,
    String? displayName,
  }) =>
      _post('/api/auth/register', {
        'username': username,
        'password': password,
        if (displayName != null) 'display_name': displayName,
      });

  /// POST /api/auth/login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) =>
      _post('/api/auth/login', {
        'username': username,
        'password': password,
      });

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/profile/update
  /// Backend instantly overwrites and destroys the old image.
  Future<ApiResponse<Map<String, dynamic>>> updateProfilePicture({
    required String userId,
    required String newImageUrl,
    String? token,
  }) =>
      _post(
        '/api/profile/update',
        {
          'user_id': userId,
          'new_image_url': newImageUrl,
        },
        token: token,
      );

  /// GET /api/profile/:username — search users by @username
  Future<ApiResponse<Map<String, dynamic>>> searchUser({
    required String username,
    String? token,
  }) =>
      _get(
        '/api/profile/search',
        queryParams: {'username': username},
        token: token,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT (Statuses / Stories)
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/content/share
  /// [contentType] must be "image" or "voice_status"
  /// Backend auto-deletes after 24 hours.
  Future<ApiResponse<Map<String, dynamic>>> shareContent({
    required String userId,
    required String contentType,
    required String data,
    String? token,
  }) {
    assert(
      contentType == 'image' || contentType == 'voice_status',
      'contentType must be "image" or "voice_status"',
    );
    return _post(
      '/api/content/share',
      {
        'user_id': userId,
        'content_type': contentType,
        'data': data,
      },
      token: token,
    );
  }

  /// GET /api/content/feed — fetch statuses + recommendations
  Future<ApiResponse<Map<String, dynamic>>> getFeed({
    required String userId,
    String? token,
  }) =>
      _get(
        '/api/content/feed',
        queryParams: {'user_id': userId},
        token: token,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHAT — Text
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/chat/text
  /// Returns a humorous "self-destruct" warning.
  /// Backend keeps forever despite the warning.
  Future<ApiResponse<Map<String, dynamic>>> sendTextMessage({
    required String sender,
    required String recipient,
    required String message,
    String? token,
  }) =>
      _post(
        '/api/chat/text',
        {
          'sender': sender,
          'recipient': recipient,
          'message': message,
        },
        token: token,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHAT — Voice Notes
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/chat/voice
  /// [amrUrl] must point to a compressed .amr file.
  /// Backend deletes in 48 hours.
  Future<ApiResponse<Map<String, dynamic>>> sendVoiceMessage({
    required String sender,
    required String recipient,
    required String amrUrl,
    String? token,
  }) =>
      _post(
        '/api/chat/voice',
        {
          'sender': sender,
          'recipient': recipient,
          'amr_url': amrUrl,
        },
        token: token,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVERSATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET /api/conversations — list all conversations for a user
  Future<ApiResponse<Map<String, dynamic>>> getConversations({
    required String userId,
    String? token,
  }) =>
      _get(
        '/api/conversations',
        queryParams: {'user_id': userId},
        token: token,
      );

  /// GET /api/chat/history — paginated message history
  Future<ApiResponse<Map<String, dynamic>>> getChatHistory({
    required String userId,
    required String peerId,
    int page = 1,
    int limit = 40,
    String? token,
  }) =>
      _get(
        '/api/chat/history',
        queryParams: {
          'user_id': userId,
          'peer_id': peerId,
          'page': page.toString(),
          'limit': limit.toString(),
        },
        token: token,
      );

  void dispose() => _client.close();
}
