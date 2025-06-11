import 'package:hive/hive.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/models/delivery_method.dart';
import 'package:kinza/core/services/time_service.dart';

int getTotalSum(Box<CartItem> cartBox) {
  return cartBox.values.fold(
    0,
    (sum, item) =>
        sum +
        (item.isWeightBased
            ? (item.price * item.weight! * 10).toInt()
            : item.price * item.quantity),
  );
}

Future<int> incrementOrderNumber() async {
  var orderNumberBox = await Hive.openBox<int>('orderNumberBox');
  int currentOrderNumber = orderNumberBox.get('orderNumber', defaultValue: 0)!;
  await orderNumberBox.put('orderNumber', currentOrderNumber + 1);
  return currentOrderNumber + 1;
}

String generateOrderDetailsString(
  int orderNumber,
  DeliveryMethod method,
  String? name,
  String? phoneNumber,
  String? address,
  String? comment,
  Box<CartItem> cartBox,
  int totalSum,
  DeliveryMethod currentDeliveryMethod,
) {
  StringBuffer details = StringBuffer();
  details
    ..writeln("Заказ №$orderNumber")
    ..writeln("Время заказа: ${TimeService.getCurrentTime()}")
    ..writeln("Доставка: ${deliveryMethodToString(method)}")
    ..writeln("Телефон: ${phoneNumber ?? 'Не указан'}")
    ..writeln("Адрес: ${address ?? 'Не указан'}")
    ..writeln("Комментарий: ${comment ?? 'Нет'}")
    ..writeln("\nПозиции заказа:");

  cartBox.values.forEach((item) {
    String itemDetail = item.isWeightBased
        ? "${item.title} - ${item.weight?.toStringAsFixed(2)} кг - ${(item.price * item.weight! * 10).toInt()} ₽"
        : "${item.title} - ${item.quantity} шт. - ${item.price * item.quantity} ₽";
    details.writeln(itemDetail);
  });

  String deliveryStatus =
      currentDeliveryMethod == DeliveryMethod.courier && totalSum >= 800
          ? "бесплатная"
          : "платная";

  details.writeln("\nДоставка: $deliveryStatus");
  details.writeln("\nИтого: $totalSum ₽");

  return details.toString();
}
