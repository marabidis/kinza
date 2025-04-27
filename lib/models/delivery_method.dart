// lib/models/delivery_method.dart

enum DeliveryMethod { pickup, courier }

String deliveryMethodToString(DeliveryMethod method) {
  switch (method) {
    case DeliveryMethod.pickup:
      return 'Самовывоз';
    case DeliveryMethod.courier:
      return 'Доставка курьером';
    default:
      return 'Неизвестный метод';
  }
}
