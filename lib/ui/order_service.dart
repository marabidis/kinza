import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';
import 'package:supabase/supabase.dart';

final supabase = SupabaseClient('https://yxsrcgwplogjoecppegy.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4c3JjZ3dwbG9nam9lY3BwZWd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMzMTIzNjIsImV4cCI6MjAwODg4ODM2Mn0.B3QQwk4SmbkIWmVicbkX70BvxxTry9MQRd3EwjYl9AU');

class Order {
  final int orderNumber;
  final String details;
  final int totalPrice;
  final String shippingAddress; // Новое поле
  final String paymentMethod; // Новое поле
  final String phone; // Новое поле
  final String timeOrder;

  Order({
    required this.orderNumber,
    required this.details,
    required this.totalPrice,
    required this.shippingAddress, // Новый параметр
    required this.paymentMethod, // Новый параметр
    required this.phone, // Новый параметр
    required this.timeOrder,
  });

  Map<String, dynamic> toJson() {
    // Преобразование времени в формат, который требуется для PostgreSQL
    String formattedTimeOrder;
    try {
      DateTime parsedDate =
          DateFormat('HH:mm, dd MMMM yyyy', 'ru_RU').parse(timeOrder);
      formattedTimeOrder = DateFormat('yyyy-MM-ddTHH:mm:ss').format(parsedDate);
    } catch (e) {
      print('Error formatting date: $e');
      formattedTimeOrder =
          timeOrder; // Если преобразование не удалось, используем исходный формат
    }

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
  static Future<bool> sendOrderToDatabase(Order order) async {
    try {
      final response = await supabase.from('orders').insert(order.toJson());

      if (response == null) {
        print("Supabase response is null");
        return false;
      }

      if (response.error != null) {
        print("Supabase Error: ${response.error?.message}");
      }

      if (response.status == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception when trying to insert order: $e');
      return false;
    }
  }
}
