import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/core/services/time_service.dart';

/// Модель заказа, которую сериализуем в Strapi.
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
    DateTime? timeOrder,
  }) : timeOrder = timeOrder ?? DateTime.parse(TimeService.getCurrentTime());

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'details': details,
      'total_price': totalPrice,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'phone': phone,
      'order_date':
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(timeOrder.toUtc()),
    };
  }
}

/// Сервис для работы с /orders в Strapi.
class OrderService {
  OrderService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  /// Создаёт заказ и возвращает его id.
  ///
  /// Бросает [Exception] если сервер вернул ≠ 2xx.
  Future<String> createOrder({
    required String jwt,
    required String phone,
    required String address,
    required String payment,
    String? comment,
    required int total,
  }) async {
    // Собираем Order — номер можете генерировать на бекенде,
    // здесь даём 0 и Strapi создаст сам.
    final order = Order(
      orderNumber: 0,
      details: comment ?? '',
      totalPrice: total,
      shippingAddress: address,
      paymentMethod: payment,
      phone: phone,
    );

    final uri = Uri.parse('${_api.baseUrl}/orders');
    final res = await _api.client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'data': order.toJson()}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['data']['id'].toString();
    }

    throw Exception(
      'OrderService: status ${res.statusCode}, body ${res.body}',
    );
  }
}
