/// lib/models/catalog_food.dart
import 'dart:convert';

import '../services/api_client.dart';
import 'product.dart';

class CatalogFoodRepository {
  final ApiClient apiClient;
  CatalogFoodRepository(this.apiClient);

  /// Загружает товары по имени категории (пример: «Пицца», «Хачапури»).
  Future<List<Product>> fetchFoodItemsByCategory(
    String categoryName, {
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await apiClient.getProducts(
        'kinzas',
        queryParameters: {
          // Фильтр по категории
          'filters[category][\$eq]': categoryName,

          // Теперь НЕ просто 'populate': '*',
          // а развернутое populate чтобы вытянуть:
          //   1) собственное поле ImageUrl,
          //   2) все ingredient_options,
          //   3) внутри каждого option вложенный ingredient + photo у него
          'populate[ImageUrl]': '*',
          'populate[ingredient_options][populate][ingredient][populate]':
              'photo',

          // Пагинация
          'pagination[page]': '$page',
          'pagination[pageSize]': '$pageSize',
        },
      );

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to load food items, status: ${response.statusCode}',
          response.body,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['data'] as List<dynamic>;
      return items
          .map<Product>((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();
    } on Object catch (e, st) {
      Error.throwWithStackTrace(e, st);
    }
  }
}

/// Исключение с телом ответа для удобного логирования.
class HttpException implements Exception {
  final String message;
  final String? responseBody;
  HttpException(this.message, [this.responseBody]);

  @override
  String toString() =>
      responseBody != null ? '$message\n$responseBody' : message;
}
