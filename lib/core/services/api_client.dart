import 'dart:convert'; // Импорт для json.encode
import 'dart:developer';

import 'package:kinza/core/constants/config.dart';
import 'package:http/http.dart' as http;
// import '../constants/config.dart' show Config; // Убедитесь, что путь правильный
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final http.Client _client = http.Client();

  // Метод для получения списка продуктов
  Future<http.Response> getProducts(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    log('[ApiClient] apiBaseUrl: "${Config.apiBaseUrl}" endpoint: "$endpoint"');
    final uri = Uri.parse('${Config.apiBaseUrl}/$endpoint')
        .replace(queryParameters: queryParameters ?? {});

    final response = await _client.get(uri);
    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');
    return response;
  }

  // Метод для отправки заказа
  Future<http.Response> sendOrder(
      String endpoint, Map<String, dynamic> body) async {
    log('[ApiClient] apiBaseUrl: "${Config.apiBaseUrl}" endpoint: "$endpoint"');
    final uri = Uri.parse('${Config.apiBaseUrl}/$endpoint');
    log('request: $uri $body');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'data': body}),
    );

    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');
    return response;
  }

  // Новый метод для получения данных
  Future<http.Response> getData(String endpoint) async {
    log('[ApiClient] apiBaseUrl: "${Config.apiBaseUrl}" endpoint: "$endpoint"');
    final uri = Uri.parse('${Config.apiBaseUrl}/api/$endpoint');

    final response = await _client.get(uri, headers: {
      // Вставьте здесь необходимые заголовки, если они нужны
    });

    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');
    return response;
  }

  // Другие методы для взаимодействия с Strapi...
}
