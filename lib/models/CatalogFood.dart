import 'dart:async';
import 'dart:convert'; // Импорт для json.decode
import 'package:http/http.dart' as http; // Добавьте http в ваш pubspec.yaml
import '../services/api_client.dart'; // Убедитесь, что путь верный
import 'product.dart'; // Импортируйте вашу модель данных

class CatalogFoodRepository {
  final ApiClient apiClient;

  CatalogFoodRepository(this.apiClient);

  Future<List<Product>> fetchFoodItemsByCategory(String category,
      {int page = 1, int pageSize = 50}) async {
    try {
      final response = await apiClient.getProducts(
        'kinzas',
        queryParameters: {
          'category': category,
          'populate[0]': 'ImageUrl',
          'populate[1]': 'category',
          'pagination[page]': page.toString(),
          'pagination[pageSize]': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'] as List<dynamic>;

        // Преобразование каждого элемента в объект Product и возврат результата
        return data.map<Product>((item) {
          return Product.fromMap(item as Map<String, dynamic>);
        }).toList();
      } else {
        throw HttpException(
            'Failed to load food items, Status Code: ${response.statusCode}',
            response.body);
      }
    } catch (e) {
      rethrow; // Добавляем rethrow для улучшенной обработки ошибок выше по цепочке
    }
  }
}

class HttpException implements Exception {
  final String message;
  final String? responseBody;

  HttpException(this.message, [this.responseBody]);

  @override
  String toString() =>
      responseBody != null ? '$message\n$responseBody' : message;
}

// Предложения по улучшению:
// 1. Добавил `try-catch` блок для улучшенной обработки ошибок и более четкого перехвата исключений.
// 2. Создан пользовательский класс `HttpException` для предоставления более полезных сообщений об ошибках, включая статус код и тело ответа, если запрос не удается.
// 3. Удалил `print()` для отладки, так как это не рекомендуется в продакшн-коде. Вместо этого рассмотрите использование логирования через пакет `logger`.