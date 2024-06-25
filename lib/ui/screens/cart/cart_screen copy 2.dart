// import 'dart:developer';
// import 'package:flutter_kinza/styles/app_constants.dart';
// import 'package:flutter_kinza/ui/widgets/cart/cart_item_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:flutter_kinza/models/cart_item.dart';
// import '../orders/success_order_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_kinza/services/order_service.dart';
// import '/forms/OrderForm.dart';
// import 'package:intl/intl.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_kinza/config.dart';
// import 'package:flutter_kinza/services/time_service.dart';

// class CartScreen extends StatefulWidget {
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   late Box<CartItem> cartBox;
//   bool _isProcessing = false;
//   final GlobalKey<OrderFormState> _orderFormKey = GlobalKey<OrderFormState>();
//   final ValueNotifier<DeliveryMethod> _deliveryMethodNotifier =
//       ValueNotifier<DeliveryMethod>(DeliveryMethod.courier);

//   @override
//   void initState() {
//     super.initState();
//     cartBox = Hive.box<CartItem>('cartBox');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ваш заказ",
//             style: AppStyles.titleTextStyle.copyWith(color: AppColors.black)),
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: AppColors.black),
//         elevation: 0.0,
//       ),
//       body: cartBox.isEmpty ? _buildEmptyCart() : _buildCartList(),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Image.asset('assets/cat.png', height: 150),
//           SizedBox(height: 20),
//           Text("Пока, тут пусто!", style: AppStyles.subtitleTextStyle),
//           SizedBox(height: 10),
//           Text(
//               "Ваша корзина пуста, перейдите по кнопке в меню и выберите понравившийся товар.",
//               style: AppStyles.bodyTextStyle,
//               textAlign: TextAlign.center),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () =>
//                 Navigator.popUntil(context, (route) => route.isFirst),
//             child: Text("Перейти в меню", style: AppStyles.buttonTextStyle),
//             style: AppStyles.elevatedButtonStyle,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartList() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: AppConstants.padding),
//         child: Column(
//           children: [
//             SizedBox(height: 16),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: cartBox.length,
//               itemBuilder: (context, index) {
//                 final item = cartBox.getAt(index);
//                 final isLastItem = index == cartBox.length - 1;
//                 return item != null
//                     ? CartItemWidget(
//                         item: item,
//                         onDelete: () => _deleteItemFromCart(index),
//                         onQuantityChanged: (newQuantity) => _updateCartItem(
//                             index, item.copyWith(quantity: newQuantity)),
//                         onWeightChanged: (newWeight) => _updateCartItem(
//                             index, item.copyWith(weight: newWeight)),
//                         isLastItem: isLastItem, // Передаем параметр
//                       )
//                     : SizedBox.shrink();
//               },
//             ),
//             SizedBox(height: 16), // Добавьте этот отступ
//             OrderForm(
//               key: _orderFormKey,
//               deliveryMethodNotifier: _deliveryMethodNotifier,
//               updateDelivery: (DeliveryMethod method) =>
//                   setState(() => _deliveryMethodNotifier.value = method),
//               onSubmit: (DeliveryMethod method, String? name,
//                   String? phoneNumber, String? address, String? comment) {
//                 if (_orderFormKey.currentState!.validate()) {
//                   _processOrder(method, name, phoneNumber, address, comment);
//                 }
//               },
//             ),
//             SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return cartBox.isEmpty
//         ? SizedBox.shrink()
//         : Padding(
//             padding: EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: _isProcessing
//                   ? null
//                   : () {
//                       if (_orderFormKey.currentState!.validate()) {
//                         final formData =
//                             _orderFormKey.currentState!.getFormData();
//                         _processOrder(
//                           formData['method'],
//                           formData['name'],
//                           formData['phoneNumber'],
//                           formData['address'],
//                           formData['comment'],
//                         );
//                       }
//                     },
//               child: _isProcessing
//                   ? CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
//                   : Text('Оформить заказ на ${_getTotalSum()} ₽',
//                       style: AppStyles.buttonTextStyle),
//               style: AppStyles.elevatedButtonStyle.copyWith(
//                 padding: MaterialStateProperty.all<EdgeInsets>(
//                   EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
//                 ),
//               ),
//             ),
//           );
//   }

//   void _deleteItemFromCart(int index) {
//     if (index >= 0 && index < cartBox.length) {
//       cartBox.deleteAt(index);
//       setState(() {});
//     }
//   }

//   void _updateCartItem(int index, CartItem updatedItem) {
//     cartBox.putAt(index, updatedItem);
//     setState(() {});
//   }

//   void _processOrder(DeliveryMethod method, String? name, String? phoneNumber,
//       String? address, String? comment) async {
//     if (!_orderFormKey.currentState!.validate()) {
//       return; // Если форма не валидна, прекратить выполнение
//     }

//     setState(() => _isProcessing = true);

//     final formData = _orderFormKey.currentState!.getFormData();

//     // Используем функцию deliveryMethodToString для получения строки
//     String deliveryMethodString = deliveryMethodToString(method);

//     int orderNum = await _incrementOrderNumber();
//     Order order = Order(
//       orderNumber: orderNum,
//       details: _generateOrderDetailsString(
//           orderNum, method, name, phoneNumber, address, comment),
//       totalPrice: _getTotalSum(),
//       shippingAddress: address ?? 'Не указан', // Значение по умолчанию
//       paymentMethod: deliveryMethodString, // Используем строку здесь
//       phone: phoneNumber ?? 'Не указан', // Значение по умолчанию
//       timeOrder: DateTime.now(),
//     );

//     await _sendOrderToTelegram(order.details);
//     await OrderService.sendOrderToDatabase(order);
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => SuccessOrderPage(orderNumber: orderNum)));

//     setState(() => _isProcessing = false);
//   }

//   int _getTotalSum() {
//     int totalSum = cartBox.values.fold(
//         0,
//         (sum, item) =>
//             sum +
//             (item.isWeightBased
//                 ? (item.price * item.weight! * 10).toInt()
//                 : item.price * item.quantity));
//     return totalSum;
//   }

//   Future<int> _incrementOrderNumber() async {
//     var orderNumberBox = await Hive.openBox<int>('orderNumberBox');
//     int currentOrderNumber =
//         orderNumberBox.get('orderNumber', defaultValue: 0)!;
//     await orderNumberBox.put('orderNumber', currentOrderNumber + 1);
//     return currentOrderNumber + 1;
//   }

//   String _generateOrderDetailsString(int orderNumber, DeliveryMethod method,
//       String? name, String? phoneNumber, String? address, String? comment) {
//     StringBuffer details = StringBuffer();
//     details
//       ..writeln("Заказ №$orderNumber")
//       ..writeln("Время заказа: ${TimeService.getCurrentTime()}");
//     if (comment != null) {
//       details.writeln("Комментарий к заказу: $comment");
//     }
//     // Добавьте детали заказа, используя `item`, `name`, `phoneNumber`, `address`, `comment`
//     return details.toString();
//   }

//   DeliveryMethod getDeliveryMethodFromString(String methodString) {
//     switch (methodString) {
//       case 'Самовывоз':
//         return DeliveryMethod.pickup;
//       case 'Доставка курьером':
//         return DeliveryMethod.courier;
//       default:
//         throw Exception('Неизвестный метод доставки: $methodString');
//     }
//   }

//   Future<void> _sendOrderToTelegram(String orderDetails) async {
//     await http.post(
//         Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage'),
//         body: {
//           'chat_id': telegramChatId,
//           'text': orderDetails,
//           'parse_mode': 'Markdown'
//         });
//   }
// }
