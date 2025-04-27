// // lib/services/order_service.dart

// import 'package:intl/intl.dart';
// import 'api_client.dart'; // Убедитесь, что путь к файлу правильный
// import '../services/time_service.dart'; // Импортируйте TimeService
// import '../models/order.dart'; // Импортируйте модель Order

// class OrderService {
//   static final ApiClient _apiClient = ApiClient(); // Создайте экземпляр ApiClient

//   /// Отправляет заказ в базу данных.
//   /// Возвращает `true`, если запрос успешен, иначе `false`.
//   static Future<bool> sendOrderToDatabase(Order order) async {
//     try {
//       final response = await _apiClient.sendOrder('orders', order.toJson());

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // Успешный запрос
//         return true;
//       } else {
//         // Неудачный запрос
//         print("Error: ${response.statusCode}");
//         print("Error message: ${response.body}");
//         return false;
//       }
//     } catch (e) {
//       print('Exception when trying to insert order: $e');
//       return false;
//     }
//   }
// }