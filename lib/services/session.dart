import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Хранит JWT accessToken и данные текущего пользователя между запусками
/// приложения (см. AuthResponse из AuthController.java).
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kToken = 'ymix_access_token';
  static const _kUser = 'ymix_current_user';

  String? _token;
  AppUser? _user;

  String? get token => _token;
  AppUser? get user => _user;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    final userJson = prefs.getString(_kUser);
    if (userJson != null) {
      _user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
  }

  Future<void> save(String token, AppUser user) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kUser, jsonEncode({
      'id': user.id,
      'username': user.username,
      'displayName': user.displayName,
      'online': user.online,
      'lastSeenAt': user.lastSeenAt?.toIso8601String(),
    }));
  }

  Future<void> clear() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }
}
