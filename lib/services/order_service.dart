import 'package:intl/intl.dart';
import 'api_client.dart'; // Убедитесь, что путь к файлу правильный
import '../services/time_service.dart'; // Импортируйте TimeService

DateTime timeOrder =
    DateTime.parse(TimeService.getCurrentTime()); // Получение текущего времени

class Order {
  final int orderNumber;
  final String details;
  final int totalPrice;
  final String shippingAddress; // Новое поле
  final String paymentMethod; // Новое поле
  final String phone; // Новое поле
  final DateTime timeOrder; // Изменено на DateTime

  Order({
    required this.orderNumber,
    required this.details,
    required this.totalPrice,
    required this.shippingAddress, // Новый параметр
    required this.paymentMethod, // Новый параметр
    required this.phone, // Новый параметр
    required this.timeOrder, // Изменено на DateTime
  });

  Map<String, dynamic> toJson() {
    String formattedTimeOrder =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(timeOrder.toUtc());

    return {
      'orderNumber': orderNumber,
      'details': details,
      'total_price': totalPrice,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'phone': phone,
      'order_date':
          formattedTimeOrder, // Обновлено для соответствия новому типу данных
    };
  }
}

class OrderService {
  static final ApiClient _apiClient =
      ApiClient(); // Создайте экземпляр ApiClient

  static Future<bool> sendOrderToDatabase(Order order) async {
    try {
      final response = await _apiClient.sendOrder('orders', order.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Успешный запрос
        return true;
      } else {
        // Неудачный запрос
        print("Error: ${response.statusCode}");
        print("Error message: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Exception when trying to insert order: $e');
      return false;
    }
  }
}
