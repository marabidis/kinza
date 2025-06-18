import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kinza/core/services/api_client.dart';

class PhoneAuthService {
  PhoneAuthService({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient.instance,
      _storage = const FlutterSecureStorage();

  final ApiClient _api;
  final FlutterSecureStorage _storage;
  static const _jwtKey = 'jwt_token';

  /* ───────── helpers ───────── */

  String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final norm =
        digits.length == 11 && digits.startsWith('8')
            ? '7${digits.substring(1)}'
            : digits;
    return '+$norm';
  }

  Map<String, String> get _json => {'Content-Type': 'application/json'};

  /* ───────── public API ─────── */

  Future<bool> sendCode(String phone) async {
    final uri = Uri.parse('${_api.baseUrl}/phone-auth/send');
    dev.log('📜 sendCode → $phone', name: 'PhoneAuth');

    try {
      final res = await _api.client
          .post(
            uri,
            headers: _json,
            body: jsonEncode({'phone': _normalize(phone)}),
          )
          .timeout(const Duration(seconds: 10));
      dev.log('📜 status ${res.statusCode}', name: 'PhoneAuth');
      return res.statusCode == 200;
    } on TimeoutException {
      debugPrint('[PhoneAuth] timeout /send');
      return false;
    } catch (e) {
      debugPrint('[PhoneAuth] error /send: $e');
      return false;
    }
  }

  Future<String?> confirmCode(String phone, String code) async {
    final uri = Uri.parse('${_api.baseUrl}/phone-auth/confirm');
    dev.log('📜 confirm → $phone : $code', name: 'PhoneAuth');

    try {
      final res = await _api.client
          .post(
            uri,
            headers: _json,
            body: jsonEncode({'phone': _normalize(phone), 'code': code}),
          )
          .timeout(const Duration(seconds: 10));

      dev.log('📜 status ${res.statusCode}', name: 'PhoneAuth');
      if (res.statusCode == 200) {
        final jwt =
            (jsonDecode(res.body) as Map<String, dynamic>)['jwt'] as String?;
        if (jwt != null) {
          await _storage.write(key: _jwtKey, value: jwt);
          dev.log(
            '📜 jwt (first 32) → ${jwt.substring(0, 32)}…',
            name: 'PhoneAuth',
          );
        }
        return jwt;
      }
      debugPrint('[PhoneAuth] confirm ${res.statusCode}: ${res.body}');
      return null;
    } on TimeoutException {
      debugPrint('[PhoneAuth] timeout /confirm');
      return null;
    } catch (e) {
      debugPrint('[PhoneAuth] error /confirm: $e');
      return null;
    }
  }

  /* ───────── token helpers ──── */

  Future<String?> get token async => _storage.read(key: _jwtKey);
  Future<void> logout() => _storage.delete(key: _jwtKey);
}
