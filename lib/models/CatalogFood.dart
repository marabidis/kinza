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

    print('Response data: ${response.body}'); // Для отладки

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'] as List<dynamic>;

      // Преобразование каждого элемента в объект Product и возврат результата
      return data.map<Product>((item) {
        return Product.fromMap(item as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load food items');
    }
  }
}
