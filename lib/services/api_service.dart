import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'session.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Тонкая обёртка над REST-эндпоинтами messenger-backend
/// (AuthController, ChatController, UserController).
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (Session.instance.token != null)
          'Authorization': 'Bearer ${Session.instance.token}',
      };

  Uri _u(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${AppConfig.httpBase}$path').replace(
      queryParameters:
          query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> _parse(http.Response res) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    String message = 'Ошибка сервера (${res.statusCode})';
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw ApiException(message, res.statusCode);
  }

  // ---------- Auth ----------

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    final res = await http.post(
      _u(AppConfig.apiAuthRegister),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'displayName': displayName,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      _u(AppConfig.apiAuthLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return _parse(res);
  }

  // ---------- Chats ----------

  Future<List<AppChat>> getChats() async {
    final res = await http.get(_u(AppConfig.apiChats), headers: _authHeaders);
    if (res.statusCode != 200) {
      throw ApiException('Не удалось загрузить чаты', res.statusCode);
    }
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return list.map((e) => AppChat.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppChat> createOrGetPrivateChat(String username) async {
    final res = await http.post(
      _u('${AppConfig.apiChats}/private'),
      headers: _authHeaders,
      body: jsonEncode({'username': username}),
    );
    final json = await _parse(res);
    return AppChat.fromJson(json);
  }

  Future<List<AppMessage>> getMessages(int chatId,
      {int page = 0, int size = 30}) async {
    final res = await http.get(
      _u('${AppConfig.apiChats}/$chatId/messages', {'page': page, 'size': size}),
      headers: _authHeaders,
    );
    if (res.statusCode != 200) {
      throw ApiException('Не удалось загрузить сообщения', res.statusCode);
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final content = json['content'] as List? ?? [];
    return content
        .map((e) => AppMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int chatId, int lastReadMessageId) async {
    await http.post(
      _u('${AppConfig.apiChats}/$chatId/read'),
      headers: _authHeaders,
      body: jsonEncode({'lastReadMessageId': lastReadMessageId}),
    );
  }

  // ---------- Users ----------

  Future<List<AppUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await http.get(
      _u(AppConfig.apiUsersSearch, {'q': query}),
      headers: _authHeaders,
    );
    if (res.statusCode != 200) {
      throw ApiException('Не удалось выполнить поиск', res.statusCode);
    }
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return list.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
  }
}
