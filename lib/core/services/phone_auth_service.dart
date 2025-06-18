import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kinza/core/services/api_client.dart';

/// Сервис SMS-авторизации к Strapi (/phone-auth/send, /confirm).
class PhoneAuthService {
  PhoneAuthService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance,
        _storage = FlutterSecureStorage(); // ← здесь без const

  final ApiClient _api;
  final FlutterSecureStorage _storage;
  static const _jwtKey = 'jwt_token';

  /* ───────── helpers ───────── */

  String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\\D'), '');
    final norm = digits.length == 11 && digits.startsWith('8')
        ? '7${digits.substring(1)}'
        : digits;
    return '+$norm';
  }

  Map<String, String> get _json => {'Content-Type': 'application/json'};

  /* ───────── публичное API ──── */

  Future<bool> sendCode(String phone) async {
    final uri = Uri.parse('${_api.baseUrl}/phone-auth/send');
    try {
      final res = await _api.client
          .post(uri,
              headers: _json, body: jsonEncode({'phone': _normalize(phone)}))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) return true;
      if (res.statusCode == 429) {
        debugPrint('[PhoneAuth] throttle 429');
      } else {
        debugPrint('[PhoneAuth] send ${res.statusCode}: ${res.body}');
      }
      return false;
    } on TimeoutException {
      debugPrint('[PhoneAuth] send timeout');
      return false;
    } catch (e) {
      debugPrint('[PhoneAuth] send error: $e');
      return false;
    }
  }

  Future<String?> confirmCode(String phone, String code) async {
    final uri = Uri.parse('${_api.baseUrl}/phone-auth/confirm');
    try {
      final res = await _api.client
          .post(uri,
              headers: _json,
              body: jsonEncode({'phone': _normalize(phone), 'code': code}))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final jwt =
            (jsonDecode(res.body) as Map<String, dynamic>)['jwt'] as String?;
        if (jwt != null) await _storage.write(key: _jwtKey, value: jwt);
        return jwt;
      }
      debugPrint('[PhoneAuth] confirm ${res.statusCode}: ${res.body}');
      return null;
    } on TimeoutException {
      debugPrint('[PhoneAuth] confirm timeout');
      return null;
    } catch (e) {
      debugPrint('[PhoneAuth] confirm error: $e');
      return null;
    }
  }

  /* ───────── token helpers ──── */

  Future<String?> get token async => _storage.read(key: _jwtKey);
  Future<void> logout() => _storage.delete(key: _jwtKey);
}
