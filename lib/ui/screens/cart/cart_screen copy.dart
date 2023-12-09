// import 'dart:developer';

// import '../../../styles/app_constants.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import '../../../models/cart_item.dart';
// import '../../widgets/cart/cart_item_control.dart';
// import '../orders/success_order_page.dart';
// import 'package:http/http.dart' as http;
// import '../../../services/order_service.dart';
// import '../../../ forms/OrderForm.dart';
// import 'package:intl/intl.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:flutter/services.dart';
// import '/config.dart';
// import '/services/time_service.dart'; // Импортируйте TimeService

// String currentTime = TimeService.getCurrentTime(); // Получение текущего времени

// ValueNotifier<DeliveryMethod> _deliveryMethodNotifier =
//     ValueNotifier<DeliveryMethod>(DeliveryMethod.courier);

// class CartScreen extends StatefulWidget {
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   late Box<CartItem> cartBox;
//   bool _isProcessing = false; // добавьте это
//   final GlobalKey<OrderFormState> _orderFormKey = GlobalKey<OrderFormState>();
//   final GlobalKey<AnimatedListState> listViewKey =
//       GlobalKey<AnimatedListState>();

//   final deliveryMethodNotifier =
//       ValueNotifier<DeliveryMethod>(DeliveryMethod.courier);

//   DeliveryMethod _currentDeliveryMethod() {
//     log("[DEBUG]: deliveryMethodNotifier: ${deliveryMethodNotifier.value}");
//     return deliveryMethodNotifier.value;
//   }

//   void _deleteItemFromCart(int index) {
//     // Проверяем, что индекс находится в допустимом диапазоне
//     if (index >= 0 && index < cartBox.length) {
//       cartBox.deleteAt(index);

//       setState(() {
//         // Этот вызов обновит UI
//       });

//       if (listViewKey.currentState != null) {
//         listViewKey.currentState!.removeItem(
//           index,
//           (context, animation) {
//             return SizedBox.shrink();
//           },
//         );
//       } else {
//         print('Ошибка: currentState is null');
//       }
//     }
//   }

//   @override
//   void dispose() {
//     deliveryMethodNotifier.dispose(); // не забудьте его освободить
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     cartBox = Hive.box<CartItem>('cartBox');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Ваш заказ",
//           style: AppStyles.titleTextStyle.copyWith(
//             color: AppColors.black, // Изменение цвета текста на черный
//           ),
//         ),
//         backgroundColor: Colors.white, // Изменение фона AppBar на белый
//         iconTheme: IconThemeData(
//           color: AppColors.black, // Изменение цвета иконок на черный
//         ),
//         elevation: 0.0, // Удаление тени
//       ),
//       bottomNavigationBar: cartBox.isEmpty
//           ? const SizedBox()
//           : Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: // Вставьте ValueListenableBuilder перед OrderForm
//                       ValueListenableBuilder<DeliveryMethod>(
//                     valueListenable: _deliveryMethodNotifier,
//                     builder: (context, deliveryMethod, child) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0, vertical: 10.0),
//                         child: Text(
//                           _getDeliveryMessage(_getTotalSum(), deliveryMethod),
//                           textAlign: TextAlign.center,
//                           style: AppStyles.subtitleTextStyle,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0, right: 16.0, bottom: 50.0), // Изменено здесь
//                   child: Container(
//                     width: 358,
//                     height: 51,
//                     child: ElevatedButton(
//                       onPressed: _isProcessing ||
//                               (_getTotalSum() < 600 &&
//                                   _currentDeliveryMethod() !=
//                                       DeliveryMethod.pickup)
//                           ? null
//                           : () async {
//                               if (_orderFormKey.currentState!.validate()) {
//                                 setState(() {
//                                   _isProcessing = true; // Начало обработки
//                                 });

//                                 final formData =
//                                     _orderFormKey.currentState!.getFormData();
//                                 String method = formData['method'] ?? '';
//                                 String name = formData['name'] ?? '';
//                                 String phoneNumber =
//                                     formData['phoneNumber'] ?? '';
//                                 String address = formData['address'] ?? '';
//                                 String comment = formData['comment'] ?? '';

//                                 int orderNum = await incrementOrderNumber();
//                                 Order order = await generateOrderDetails(
//                                   orderNum,
//                                   method,
//                                   name,
//                                   phoneNumber,
//                                   address,
//                                   comment,
//                                 );
//                                 await sendOrderToTelegram(order.details);
//                                 await OrderService.sendOrderToDatabase(order);

//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => SuccessOrderPage(
//                                         orderNumber:
//                                             orderNum), // Используйте orderNum здесь
//                                   ),
//                                 );

//                                 setState(() {
//                                   _isProcessing = false; // Завершение обработки
//                                 });
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Пожалуйста, заполните все обязательные поля формы!',
//                                     ),
//                                   ),
//                                 );
//                                 HapticFeedback.heavyImpact();
//                               }
//                             },
//                       style: AppStyles.elevatedButtonStyle,
//                       child: _isProcessing
//                           ? CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             )
//                           : (_getTotalSum() < 600 &&
//                                   _currentDeliveryMethod() !=
//                                       DeliveryMethod.pickup
//                               ? Text(
//                                   'Добавьте товары на ${600 - _getTotalSum()} ₽',
//                                   style: AppStyles.buttonTextStyle,
//                                 )
//                               : Text(
//                                   'Оформить заказ на ${_getTotalSum()} ₽',
//                                   style: AppStyles.buttonTextStyle,
//                                 )),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//       body: cartBox.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/cat.png', height: 150),
//                   SizedBox(height: 20),
//                   Text(
//                     "Пока, тут пусто!",
//                     style: AppStyles.subtitleTextStyle,
//                   ),
//                   SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text(
//                       "Ваша корзина пуста, перейдите по кнопке в меню и выберите понравившийся товар.",
//                       style: AppStyles.bodyTextStyle,
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AppConstants.padding,
//                     ),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           HapticFeedback.mediumImpact();
//                           Navigator.popUntil(
//                               context,
//                               (route) => route
//                                   .isFirst); // Этот метод приведет вас к первой странице в стеке маршрутов (обычно главной).
//                         },
//                         child: Text(
//                           "Перейти в меню",
//                           style: AppStyles.buttonTextStyle,
//                         ),
//                         style: AppStyles.elevatedButtonStyle,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 16),
//                   ListView.separated(
//                     key: listViewKey,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: cartBox.length,
//                     separatorBuilder: (_, __) => const Divider(
//                       height: 16,
//                       thickness: 1,
//                       indent: 16,
//                       endIndent: 16,
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = cartBox.getAt(index);
//                       if (item == null) return SizedBox.shrink();

//                       return Column(
//                         children: [
//                           ListTile(
//                             leading: Container(
//                               width: 70,
//                               height: 70,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(15),
//                                 image: DecorationImage(
//                                   image: CachedNetworkImageProvider(item
//                                           .thumbnailUrl ??
//                                       'fallback_image_url'), // Используйте CachedNetworkImageProvider здесь
//                                   fit: BoxFit.contain,
//                                   onError: (exception, stackTrace) => print(
//                                       'Ошибка загрузки изображения: $exception'),
//                                 ),
//                               ),
//                             ),
//                             title: Container(
//                               child: Text(
//                                 item.title,
//                                 style: TextStyle(
//                                   fontFamily: 'Roboto',
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color.fromRGBO(16, 25, 40, 1),
//                                 ),
//                               ),
//                             ),
//                             subtitle: Container(
//                               child: Text(
//                                 item.weight != null
//                                     ? '${item.weight} кг'
//                                     : 'Вес не указан',
//                                 style: TextStyle(
//                                   fontFamily: 'Roboto',
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                             trailing: Container(
//                               child: IconButton(
//                                 padding: EdgeInsets.zero,
//                                 icon: Icon(Icons.delete,
//                                     color: const Color.fromARGB(
//                                         255, 116, 116, 116)),
//                                 onPressed: () {
//                                   _deleteItemFromCart(index);
//                                 },
//                               ),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(
//                               left: 70 + 30,
//                               bottom: 8,
//                             ),
//                             child: CartItemControl(
//                               item: item,
//                               onQuantityChanged: (newQuantity) {
//                                 if (newQuantity <= 0) {
//                                   _deleteItemFromCart(index);
//                                 } else {
//                                   CartItem updatedItem = CartItem(
//                                     id: item.id,
//                                     title: item.title,
//                                     price: item.price,
//                                     weight: item.weight,
//                                     thumbnailUrl: item.thumbnailUrl,
//                                     quantity: newQuantity,
//                                     isWeightBased:
//                                         item.isWeightBased, // добавьте это поле
//                                     minimumWeight:
//                                         item.minimumWeight, // добавьте это поле
//                                     unit: item.unit, // добавьте это поле
//                                   );

//                                   cartBox.putAt(index, updatedItem);
//                                   setState(() {});
//                                 }
//                               },
//                               onWeightChanged: (newWeight) {
//                                 // Обновляем вес товара
//                                 CartItem updatedItem = CartItem(
//                                   id: item.id,
//                                   title: item.title,
//                                   price: item.price,
//                                   weight: newWeight,
//                                   thumbnailUrl: item.thumbnailUrl,
//                                   quantity: item.quantity,
//                                   isWeightBased:
//                                       item.isWeightBased, // добавьте это поле
//                                   minimumWeight:
//                                       item.minimumWeight, // добавьте это поле
//                                   unit: item.unit, // добавьте это поле
//                                 );

//                                 cartBox.putAt(index, updatedItem);
//                                 setState(() {});
//                               },
//                               isWeightBased: item
//                                   .isWeightBased, // Предполагая, что у вас есть такой флаг в модели CartItem
//                               minWeight:
//                                   0.1, // Минимальный вес товара (можно адаптировать под свои нужды)
//                               maxWeight:
//                                   999, // Максимальный вес товара (можно адаптировать под свои нужды)
//                               maxQuantity:
//                                   999, // Максимальное количество товара (можно адаптировать под свои нужды)
//                               onAddToCart: () {
//                                 // ваш код для добавления товара в корзину
//                               },
//                               isItemInCart:
//                                   true, // или false, в зависимости от того, находится ли товар в корзине
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                   OrderForm(
//                     deliveryMethodNotifier: _deliveryMethodNotifier,
//                     updateDelivery: (v) {
//                       setState(() {
//                         deliveryMethodNotifier.value = v;
//                       });
//                     },
//                     key: _orderFormKey,
//                     onSubmit: (method, name, phoneNumber, address, comment) {
//                       // Вычисляем общую сумму заказа
//                       int totalPrice = _getTotalSum();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   int _getTotalSum() {
//     int totalSum = 0;
//     for (int i = 0; i < cartBox.length; i++) {
//       CartItem? item = cartBox.getAt(i);
//       if (item != null) {
//         if (item.isWeightBased) {
//           totalSum += (item.price * (item.weight ?? 0) * 10)
//               .toInt(); // умножаем на 10, если цена указана за 0.1 кг
//         } else {
//           totalSum += (item.price * item.quantity);
//         }
//       }
//     }
//     log("[DEBUG]: totalSum: $totalSum");
//     return totalSum;
//   }

//   String _getDeliveryMessage(int totalSum, DeliveryMethod deliveryMethod) {
//     if (deliveryMethod == DeliveryMethod.pickup) {
//       return "Будем ждать Вас!";
//     } else if (totalSum >= 800) {
//       return "Доставка будет бесплатной";
//     } else {
//       return "Доставка по городу 100 руб";
//     }
//   }

//   Future<int> incrementOrderNumber() async {
//     var orderNumberBox = await Hive.openBox<int>('orderNumberBox');

//     // Если ячейка с номером заказа пуста, инициализируем её номером 1
//     if (orderNumberBox.isEmpty) {
//       await orderNumberBox.put('orderNumber', 1);
//       return 1;
//     } else {
//       int currentOrderNumber = orderNumberBox.get('orderNumber')!;
//       await orderNumberBox.put('orderNumber', currentOrderNumber + 1);
//       return currentOrderNumber + 1;
//     }
//   }

//   Future<Order> generateOrderDetails(int orderNumber, String method,
//       String name, String phoneNumber, String address, String comment) async {
//     StringBuffer details = StringBuffer();

//     details.writeln("Заказ №$orderNumber");
//     details.writeln(
//         "Время заказа: ${TimeService.getCurrentTime()}"); // Добавляем время заказа

//     details.writeln("Детали заказа:");
//     details.writeln("Метод: $method");
//     details.writeln("Имя: $name");
//     details.writeln("Телефон: $phoneNumber");
//     details.writeln("Адрес: $address");
//     details.writeln("Комментарий: $comment");

//     for (int i = 0; i < cartBox.length; i++) {
//       final item = cartBox.getAt(i);
//       if (item != null) {
//         if (item.isWeightBased) {
//           details.writeln(
//               "- ${item.title} (вес: ${item.weight?.toStringAsFixed(1)} кг, Цена за 0.1 кг: ${item.price} ₽)");
//         } else {
//           details.writeln(
//               "- ${item.title} (кол-во: ${item.quantity}, Цена за шт: ${item.price} ₽)");
//         }
//       }
//     }
//     details.writeln("Общий итог: ${_getTotalSum()} ₽");

//     return Order(
//       orderNumber: orderNumber,
//       details: details.toString(),
//       totalPrice: _getTotalSum(),
//       shippingAddress: address,
//       paymentMethod: method,
//       phone: phoneNumber,
//       timeOrder: DateFormat('yyyy-MM-dd HH:mm:ss').parse(TimeService
//           .getCurrentTime()), // передаем преобразованное текущее время в параметр timeOrder
//     );
//   }

//   Future<void> sendOrderToTelegram(String orderDetails) async {
//     final String url =
//         'https://api.telegram.org/bot$telegramBotToken/sendMessage';

//     await http.post(
//       Uri.parse(url),
//       body: {
//         'chat_id': telegramChatId,
//         'text': orderDetails,
//         'text': orderDetails,
//         'parse_mode': 'Markdown',
//       },
//     );
//   }
// }
