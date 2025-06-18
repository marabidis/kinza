import 'package:intl/intl.dart';
import 'package:kinza/core/services/api_client.dart'; // Убедитесь, что путь к файлу правильный
import 'package:kinza/core/services/time_service.dart'; // Импортируйте TimeService

DateTime timeOrder =
    DateTime.parse(TimeService.getCurrentTime()); // Получение текущего времени

class Order {
  final int orderNumber;
  final String details;
  final int totalPrice;
  final String shippingAddress;
  final String paymentMethod;
  final String phone;
  final DateTime timeOrder;

  Order({
    required this.orderNumber,
    required this.details,
    required this.totalPrice,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.phone,
    required this.timeOrder,
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
      'order_date': formattedTimeOrder,
    };
  }
}

class OrderService {
  static final ApiClient _apiClient = ApiClient();

  static Future<bool> sendOrderToDatabase(Order order) async {
    try {
      final response = await _apiClient.sendOrder('orders', order.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
