// lib/models/order.dart

import 'package:intl/intl.dart';

/// Модель заказа.
class Order {
  /// Номер заказа.
  final int orderNumber;

  /// Детали заказа.
  final String details;

  /// Общая сумма заказа.
  final int totalPrice;

  /// Адрес доставки.
  final String shippingAddress;

  /// Метод оплаты или доставки.
  final String paymentMethod;

  /// Телефон клиента.
  final String phone;

  /// Время оформления заказа.
  final DateTime timeOrder;

  /// Конструктор класса [Order].
  Order({
    required this.orderNumber,
    required this.details,
    required this.totalPrice,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.phone,
    required this.timeOrder,
  });

  /// Преобразует объект [Order] в JSON формат.
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

  /// Создает объект [Order] из JSON формата.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderNumber: json['orderNumber'],
      details: json['details'],
      totalPrice: json['total_price'],
      shippingAddress: json['shipping_address'],
      paymentMethod: json['payment_method'],
      phone: json['phone'],
      timeOrder: DateTime.parse(json['order_date']),
    );
  }
}
