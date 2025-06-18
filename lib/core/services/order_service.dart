import 'dart:convert';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/core/services/time_service.dart';

class Order {
  Order({
    required this.orderNumber,
    required this.totalPrice,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.phone,
    required this.details,
    DateTime? timeOrder,
  }) : timeOrder = timeOrder ?? DateTime.parse(TimeService.getCurrentTime());

  final int orderNumber;
  final int totalPrice;
  final String shippingAddress;
  final String paymentMethod;
  final String phone;
  final String details;
  final DateTime timeOrder;

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'total_price': totalPrice,
    'shipping_address': shippingAddress,
    'payment_method': paymentMethod,
    'phone': phone,
    'details': details,
    'order_date': DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(timeOrder.toUtc()),
  };
}

class OrderService {
  OrderService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;
  final ApiClient _api;

  Future<String> createOrder({
    required String jwt,
    required String phone,
    required String address,
    required String payment,
    required int total,
    String? comment,
  }) async {
    final order = Order(
      orderNumber: 0,
      totalPrice: total,
      shippingAddress: address,
      paymentMethod: payment,
      phone: phone,
      details: comment ?? '',
    );

    final uri = Uri.parse('${_api.baseUrl}/orders');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${jwt.trim()}',
    };

    dev.log('📜 POST $uri', name: 'OrderService');
    dev.log('📜 headers → $headers', name: 'OrderService');

    final res = await _api.client.post(
      uri,
      headers: headers,
      body: jsonEncode({'data': order.toJson()}),
    );

    dev.log('📜 status ${res.statusCode}', name: 'OrderService');
    dev.log(res.body, name: 'OrderService');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final id = (jsonDecode(res.body) as Map<String, dynamic>)['data']['id'];
      return id.toString();
    }

    throw Exception('OrderService: ${res.statusCode} ${res.body}');
  }
}
