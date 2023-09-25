import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/cart_item.dart';
import './cart_item_control.dart';
import './success_order_page.dart';
import 'package:http/http.dart' as http;
import './order_service.dart';
import 'widgets/OrderForm.dart';

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

String getCurrentTime() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Europe/Samara'));

  // Если требуется только время
  final DateFormat formatter = DateFormat('HH:mm:ss', 'ru_RU');

  // Если требуется дата и время
  // final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'ru_RU');

  log("TIME: ${now.subtract(const Duration(hours: 1)).subtract(const Duration(minutes: 6))}");
  return formatter.format(now
      .subtract(const Duration(hours: 1))
      .subtract(const Duration(minutes: 6)));
}

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Box<CartItem> cartBox;
  bool _isProcessing = false; // добавьте это
  final GlobalKey<OrderFormState> _orderFormKey = GlobalKey<OrderFormState>();
  final GlobalKey<AnimatedListState> listViewKey =
      GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cartBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ваш заказ",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: cartBox.isEmpty
          ? const SizedBox()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Итого: ${_getTotalSum()} ₽',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 358,
                    height: 51,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (_orderFormKey.currentState!.validate()) {
                                setState(() {
                                  _isProcessing = true; // Начало обработки
                                });

                                final formData =
                                    _orderFormKey.currentState!.getFormData();
                                String method = formData['method'] ?? '';
                                String name = formData['name'] ?? '';
                                String phoneNumber =
                                    formData['phoneNumber'] ?? '';
                                String address = formData['address'] ?? '';
                                String comment = formData['comment'] ?? '';

                                int orderNum = await incrementOrderNumber();
                                Order order = await generateOrderDetails(
                                  orderNum,
                                  method,
                                  name,
                                  phoneNumber,
                                  address,
                                  comment,
                                );
                                await sendOrderToTelegram(order.details);
                                await OrderService.sendOrderToDatabase(order);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SuccessOrderPage()),
                                );

                                setState(() {
                                  _isProcessing = false; // Завершение обработки
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Пожалуйста, заполните все обязательные поля формы!')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(149, 202, 32, 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ) // индикатор загрузки внутри кнопки
                          : Text(
                              'Оформить заказ на ${_getTotalSum()} ₽',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
      body: cartBox.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/pizza_box.png'),
                  SizedBox(height: 20),
                  Text("Корзина пустая"),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ListView.separated(
                    key: listViewKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartBox.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 16,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = cartBox.getAt(index);
                      if (item == null) return SizedBox.shrink();

                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.contain,
                                  onError: (exception, stackTrace) => print(
                                      'Ошибка загрузки изображения: $exception'),
                                ),
                              ),
                            ),
                            title: Container(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(16, 25, 40, 1),
                                ),
                              ),
                            ),
                            subtitle: Container(
                              child: Text(
                                item.weight != null
                                    ? '${item.weight} гр.'
                                    : 'Вес не указан',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            trailing: Container(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteItemFromCart(index);
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              left: 70 + 30,
                              bottom: 8,
                            ),
                            child: CartItemControl(
                                item: item,
                                onQuantityChanged: (newQuantity) {
                                  if (newQuantity <= 0) {
                                    _deleteItemFromCart(index);
                                  } else {
                                    CartItem updatedItem = CartItem(
                                      id: item.id,
                                      title: item.title,
                                      price: item.price,
                                      weight: item.weight,
                                      imageUrl: item.imageUrl,
                                      quantity: newQuantity,
                                    );
                                    cartBox.putAt(index, updatedItem);
                                    setState(() {});
                                  }
                                }),
                          ),
                        ],
                      );
                    },
                  ),
                  OrderForm(
                    key: _orderFormKey,
                    onSubmit: (method, name, phoneNumber, address, comment) {
                      // Вычисляем общую сумму заказа
                      int totalPrice = _getTotalSum();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  int _getTotalSum() {
    int sum = 0;
    for (int i = 0; i < cartBox.length; i++) {
      final item = cartBox.getAt(i);
      if (item != null) {
        sum += item.quantity * item.price;
      }
    }
    return sum;
  }

  Future<int> incrementOrderNumber() async {
    var orderNumberBox = await Hive.openBox<int>('orderNumberBox');

    // Если ячейка с номером заказа пуста, инициализируем её номером 1
    if (orderNumberBox.isEmpty) {
      await orderNumberBox.put('orderNumber', 1);
      return 1;
    } else {
      int currentOrderNumber = orderNumberBox.get('orderNumber')!;
      await orderNumberBox.put('orderNumber', currentOrderNumber + 1);
      return currentOrderNumber + 1;
    }
  }

  Future<Order> generateOrderDetails(int orderNumber, String method,
      String name, String phoneNumber, String address, String comment) async {
    StringBuffer details = StringBuffer();

    details.writeln("Заказ №$orderNumber");
    details
        .writeln("Время заказа: ${getCurrentTime()}"); // Добавляем время заказа

    details.writeln("Детали заказа:");
    details.writeln("Метод: $method");
    details.writeln("Имя: $name");
    details.writeln("Телефон: $phoneNumber");
    details.writeln("Адрес: $address");
    details.writeln("Комментарий: $comment");

    for (int i = 0; i < cartBox.length; i++) {
      final item = cartBox.getAt(i);
      if (item != null) {
        details.writeln(
            "- ${item.title} (кол-во: ${item.quantity}, Цена за шт: ${item.price} ₽)");
      }
    }
    details.writeln("Общий итог: ${_getTotalSum()} ₽");

    return Order(
      orderNumber: orderNumber,
      details: details.toString(),
      totalPrice: _getTotalSum(),
      shippingAddress: address,
      paymentMethod: method,
      phone: phoneNumber,
      timeOrder:
          getCurrentTime(), // передаем текущее время в параметр timeOrder
    );
  }

  Future<void> sendOrderToTelegram(String orderDetails) async {
    const String token =
        '5016384464:AAHc2iyx2AJLTZngbE8yJtuXxuFjcxSeuJM'; // Ваш токен бота
    const String chatId = '58764404'; // Ваш идентификатор чата

    final String url = 'https://api.telegram.org/bot$token/sendMessage';

    await http.post(
      Uri.parse(url),
      body: {
        'chat_id': chatId,
        'text': orderDetails,
        'parse_mode': 'Markdown',
      },
    );
  }

  void _deleteItemFromCart(int index) {
    // Проверяем, что индекс находится в допустимом диапазоне
    if (index >= 0 && index < cartBox.length) {
      cartBox.deleteAt(index);

      setState(() {
        // Этот вызов обновит UI
      });

      if (listViewKey.currentState != null) {
        listViewKey.currentState!.removeItem(
          index,
          (context, animation) {
            return SizedBox.shrink();
          },
        );
      } else {
        print('Ошибка: currentState is null');
      }
    }
  }
}
