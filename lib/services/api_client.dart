import 'dart:convert'; // Импорт для json.encode
import 'package:http/http.dart' as http;
import '../config.dart' show Config; // Убедитесь, что путь правильный
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final http.Client _client = http.Client();

  // Метод для получения списка продуктов
  Future<http.Response> getProducts(String endpoint,
      {Map<String, String>? queryParameters}) async {
    print('[ApiClient] strapiUrl: "${Config.strapiUrl}" endpoint: "$endpoint"');
    final uri = Uri.parse('${Config.strapiUrl}/api/$endpoint')
        .replace(queryParameters: queryParameters ?? {});

    final response = await _client.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  // Метод для отправки заказа
  Future<http.Response> sendOrder(
      String endpoint, Map<String, dynamic> body) async {
    print('[ApiClient] strapiUrl: "${Config.strapiUrl}" endpoint: "$endpoint"');
    final uri = Uri.parse('${Config.strapiUrl}/api/$endpoint');
    print('request: ${uri} ${body}');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'data': body}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  // Новый метод для получения данных
  Future<http.Response> getData(String endpoint) async {
    print('[ApiClient] strapiUrl: "${Config.strapiUrl}" endpoint: "$endpoint"');
    final uri = Uri.parse('${Config.strapiUrl}/api/$endpoint');

    final response = await _client.get(uri, headers: {
      // Вставьте здесь необходимые заголовки, если они нужны
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  // Другие методы для взаимодействия с Strapi...
}
