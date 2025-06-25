import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:kinza/core/constants/config.dart';

/// Универсальный HTTP-клиент для работы со Strapi API.
/// Используйте [ApiClient.instance] — это единственный
/// экземпляр на всё приложение.
class ApiClient {
  /* ───────── Singleton ───────── */

  ApiClient._() : _client = http.Client();
  static final ApiClient instance = ApiClient._();

  /* ───────── Fields ───────── */

  final http.Client _client;

  /// Публичный доступ к http-клиенту (`post`, `get`, …).
  http.Client get client => _client;

  /// Базовый URL (например `http://localhost:1337/api`).
  /// Можно переопределить на лету для Android-эмулятора:
  /// `ApiClient.instance.baseUrlOverride = 'http://10.0.2.2:1337/api';`
  String _override = '';
  String get baseUrl => _override.isNotEmpty ? _override : Config.apiBaseUrl;
  set baseUrlOverride(String v) => _override = v;

  /* ───────── Helpers ───────── */

  Uri _uri(String endpoint, [Map<String, String>? qp]) =>
      Uri.parse('$baseUrl/$endpoint').replace(queryParameters: qp);

  void _logResp(http.Response r) =>
      log('Response ${r.statusCode}: ${r.body}', name: 'ApiClient');

  /* ───────── HIGH-LEVEL METHODS ───────── */

  /// Пример GET (каталог продуктов).
  Future<http.Response> getProducts(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _uri(endpoint, queryParameters);
    log('GET  $uri', name: 'ApiClient');
    final res = await _client.get(uri);
    _logResp(res);
    return res;
  }

  /// Пример POST (создать заказ).
  Future<http.Response> sendOrder(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = _uri(endpoint);
    log('POST $uri\nBODY: $body', name: 'ApiClient');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'data': body}),
    );
    _logResp(res);
    return res;
  }

  /// Универсальный GET без параметров.
  Future<http.Response> getData(String endpoint) async {
    final uri = _uri(endpoint);
    log('GET  $uri', name: 'ApiClient');
    final res = await _client.get(uri);
    _logResp(res);
    return res;
  }
}
