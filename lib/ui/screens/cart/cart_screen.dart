import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import '../orders/success_order_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_kinza/services/order_service.dart';
import '/forms/OrderForm.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/config.dart';
import 'package:flutter_kinza/services/time_service.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Box<CartItem> cartBox;
  bool _isProcessing = false;
  final GlobalKey<OrderFormState> _orderFormKey = GlobalKey<OrderFormState>();
  final ValueNotifier<DeliveryMethod> _deliveryMethodNotifier =
      ValueNotifier<DeliveryMethod>(DeliveryMethod.courier);
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cartBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ваш заказ",
            style: AppStyles.titleTextStyle.copyWith(color: AppColors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.black),
        elevation: 0.0,
      ),
      body: cartBox.isEmpty ? _buildEmptyCart() : _buildCartList(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/cat.png', height: 150),
          SizedBox(height: 20),
          Text("Пока, тут пусто!", style: AppStyles.subtitleTextStyle),
          SizedBox(height: 10),
          Text(
              "Ваша корзина пуста, перейдите по кнопке в меню и выберите понравившийся товар.",
              style: AppStyles.bodyTextStyle,
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("Перейти в меню", style: AppStyles.buttonTextStyle),
            style: AppStyles.elevatedButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.padding),
        child: Column(
          children: [
            SizedBox(height: 16),
            AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              initialItemCount: cartBox.length,
              itemBuilder: (context, index, animation) {
                final item = cartBox.getAt(index);
                final isLastItem = index == cartBox.length - 1;
                return item != null
                    ? _buildCartItem(item, index, animation, isLastItem)
                    : SizedBox.shrink();
              },
            ),
            SizedBox(height: 16), // Добавьте этот отступ
            OrderForm(
              key: _orderFormKey,
              deliveryMethodNotifier: _deliveryMethodNotifier,
              updateDelivery: (DeliveryMethod method) =>
                  setState(() => _deliveryMethodNotifier.value = method),
              onSubmit: (DeliveryMethod method, String? name,
                  String? phoneNumber, String? address, String? comment) {
                if (_orderFormKey.currentState!.validate()) {
                  _processOrder(method, name, phoneNumber, address, comment);
                }
              },
              totalPrice: _getTotalSum(), // Передаем общую сумму заказа
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      CartItem item, int index, Animation<double> animation, bool isLastItem) {
    return SizeTransition(
      sizeFactor: animation,
      child: CartItemWidget(
        item: item,
        onDelete: () => _deleteItemFromCart(index),
        onQuantityChanged: (newQuantity) =>
            _updateCartItem(index, item.copyWith(quantity: newQuantity)),
        onWeightChanged: (newWeight) =>
            _updateCartItem(index, item.copyWith(weight: newWeight)),
        isLastItem: isLastItem, // Передаем параметр
      ),
    );
  }

  void _showDeliveryDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Условия доставки',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildConditionItem(
                  'При заказе от 800 ₽ - доставка курьером бесплатная.'),
              Divider(color: Colors.grey),
              _buildConditionItem(
                  'При заказе до 800 ₽ - стоимость доставки 100 ₽.'),
              Divider(color: Colors.grey),
              _buildConditionItem(
                  'Доставка осуществляется по городу ежедневно с 9:00 до 21:00.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionItem(String condition) {
    return Text(
      condition,
      style: TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  Widget _buildBottomNavigationBar() {
    final totalSum = _getTotalSum();
    return cartBox.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_deliveryMethodNotifier.value == DeliveryMethod.courier)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          totalSum >= 800
                              ? 'Бесплатная доставка'
                              : 'Доставка по городу от 100 ₽, до бесплатной доставки еще нужно ${800 - totalSum} ₽',
                          style: AppStyles.bodyTextStyle
                              .copyWith(color: AppColors.green),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.info_outline, color: AppColors.green),
                        onPressed: () => _showDeliveryDetails(context),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isProcessing ||
                          (_deliveryMethodNotifier.value ==
                                  DeliveryMethod.courier &&
                              totalSum < 800)
                      ? null
                      : () {
                          _scrollToOrderForm();
                          if (_orderFormKey.currentState!.validate()) {
                            final formData =
                                _orderFormKey.currentState!.getFormData();
                            _processOrder(
                              formData['method'],
                              formData['name'],
                              formData['phoneNumber'],
                              formData['address'],
                              formData['comment'],
                            );
                          }
                        },
                  child: _isProcessing
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text(
                          totalSum >= 800 ||
                                  _deliveryMethodNotifier.value ==
                                      DeliveryMethod.pickup
                              ? 'Оформить заказ на ${totalSum} ₽'
                              : 'Добавьте товаров еще на ${800 - totalSum} ₽',
                          style: AppStyles.buttonTextStyle,
                        ),
                  style: AppStyles.elevatedButtonStyle.copyWith(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 48)),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  void _scrollToOrderForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  void _deleteItemFromCart(int index) {
    final item = cartBox.getAt(index);
    if (item != null) {
      cartBox.deleteAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) =>
            _buildCartItem(item, index, animation, index == cartBox.length - 1),
        duration: Duration(milliseconds: 300),
      );
    }
    setState(() {});
  }

  void _updateCartItem(int index, CartItem updatedItem) {
    cartBox.putAt(index, updatedItem);
    setState(() {});
  }

  void _processOrder(DeliveryMethod method, String? name, String? phoneNumber,
      String? address, String? comment) async {
    if (!_orderFormKey.currentState!.validate()) {
      return; // Если форма не валидна, прекратить выполнение
    }

    setState(() => _isProcessing = true);

    final formData = _orderFormKey.currentState!.getFormData();

    // Используем функцию deliveryMethodToString для получения строки
    String deliveryMethodString = deliveryMethodToString(method);

    int orderNum = await _incrementOrderNumber();
    Order order = Order(
      orderNumber: orderNum,
      details: _generateOrderDetailsString(
          orderNum, method, name, phoneNumber, address, comment),
      totalPrice: _getTotalSum(),
      shippingAddress: address ?? 'Не указан', // Значение по умолчанию
      paymentMethod: deliveryMethodString, // Используем строку здесь
      phone: phoneNumber ?? 'Не указан', // Значение по умолчанию
      timeOrder: DateTime.now(),
    );

    await _sendOrderToTelegram(order.details);
    await OrderService.sendOrderToDatabase(order);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SuccessOrderPage(orderNumber: orderNum)));

    setState(() => _isProcessing = false);
  }

  int _getTotalSum() {
    int totalSum = cartBox.values.fold(
        0,
        (sum, item) =>
            sum +
            (item.isWeightBased
                ? (item.price * item.weight! * 10).toInt()
                : item.price * item.quantity));
    return totalSum;
  }

  Future<int> _incrementOrderNumber() async {
    var orderNumberBox = await Hive.openBox<int>('orderNumberBox');
    int currentOrderNumber =
        orderNumberBox.get('orderNumber', defaultValue: 0)!;
    await orderNumberBox.put('orderNumber', currentOrderNumber + 1);
    return currentOrderNumber + 1;
  }

  String _generateOrderDetailsString(int orderNumber, DeliveryMethod method,
      String? name, String? phoneNumber, String? address, String? comment) {
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
        _deliveryMethodNotifier.value == DeliveryMethod.courier &&
                _getTotalSum() >= 800
            ? "бесплатная"
            : "платная";

    details.writeln("\nДоставка: $deliveryStatus");
    details.writeln("\nИтого: ${_getTotalSum()} ₽");

    return details.toString();
  }

  DeliveryMethod getDeliveryMethodFromString(String methodString) {
    switch (methodString) {
      case 'Самовывоз':
        return DeliveryMethod.pickup;
      case 'Доставка курьером':
        return DeliveryMethod.courier;
      default:
        throw Exception('Неизвестный метод доставки: $methodString');
    }
  }

  Future<void> _sendOrderToTelegram(String orderDetails) async {
    await http.post(
        Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage'),
        body: {
          'chat_id': telegramChatId,
          'text': orderDetails,
          'parse_mode': 'Markdown'
        });
  }
}
