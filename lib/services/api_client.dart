import 'package:http/http.dart' as http;
import '../config.dart' show Config;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<http.Response> getProducts(String endpoint,
      {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse('${Config.strapiUrl}/api/$endpoint')
        .replace(queryParameters: queryParameters ?? {});

    final response = await _client.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  // Другие методы для взаимодействия с Strapi
}
