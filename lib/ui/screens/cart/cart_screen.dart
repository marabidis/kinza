import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_widget.dart';
import 'package:flutter_kinza/ui/widgets/cart/empty_cart_screen.dart';
import 'package:hive/hive.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import '../orders/success_order_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_kinza/services/order_service.dart';
import '/forms/OrderForm.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shimmer/shimmer.dart';
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
    final isEmpty = cartBox.isEmpty;

    return Scaffold(
      backgroundColor: Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(
          "Ваш заказ",
          style: AppStyles.titleTextStyle.copyWith(color: AppColors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.black),
        elevation: 0.0,
      ),
      body: isEmpty ? EmptyCartScreen() : _buildCartList(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCartList() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.padding),
            child: AnimatedList(
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
          ),
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.padding),
            child: OrderForm(
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
              totalPrice: _getTotalSum(),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      CartItem item, int index, Animation<double> animation, bool isLastItem) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLastItem ? 0 : 10),
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: 0.0,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: CartItemWidget(
            item: item,
            onDelete: () => _deleteItemFromCart(index),
            onQuantityChanged: (newQuantity) =>
                _updateCartItem(index, item.copyWith(quantity: newQuantity)),
            onWeightChanged: (newWeight) =>
                _updateCartItem(index, item.copyWith(weight: newWeight)),
            isLastItem: isLastItem,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final totalSum = _getTotalSum();
    final isEmpty = cartBox.isEmpty;
    return isEmpty
        ? SizedBox.shrink()
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: SafeArea(
              top: false,
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
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: totalSum >= 800
                                  ? AppColors.green
                                  : AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.info_outline, color: AppColors.green),
                          onPressed: () => _showDeliveryDetails(context),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: ElevatedButton(
                      key: ValueKey(_isProcessing),
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
                      style: AppStyles.elevatedButtonStyle.copyWith(
                        minimumSize: MaterialStateProperty.all<Size>(
                            Size(double.infinity, 50)),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                              vertical: AppConstants.paddingSmall),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          _isProcessing ||
                                  (_deliveryMethodNotifier.value ==
                                          DeliveryMethod.courier &&
                                      totalSum < 800)
                              ? AppColors.whitegrey.withOpacity(0.4)
                              : AppColors.green,
                        ),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              totalSum >= 800 ||
                                      _deliveryMethodNotifier.value ==
                                          DeliveryMethod.pickup
                                  ? 'Оформить заказ на ${totalSum} ₽'
                                  : 'Добавьте товаров еще на ${800 - totalSum} ₽',
                              style: AppStyles.buttonTextStyle,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _scrollToOrderForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showDeliveryDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.87),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Условия доставки',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              _buildConditionItem(
                  'При заказе от 800 ₽ — доставка курьером бесплатная.'),
              Divider(color: Colors.grey.shade700),
              _buildConditionItem(
                  'При заказе до 800 ₽ — стоимость доставки 100 ₽.'),
              Divider(color: Colors.grey.shade700),
              _buildConditionItem(
                  'Доставка по городу ежедневно с 9:00 до 21:00.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionItem(String condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        condition,
        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
      ),
    );
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
      return;
    }
    setState(() => _isProcessing = true);
    final formData = _orderFormKey.currentState!.getFormData();

    String deliveryMethodString = deliveryMethodToString(method);

    int orderNum = await _incrementOrderNumber();
    Order order = Order(
      orderNumber: orderNum,
      details: _generateOrderDetailsString(
          orderNum, method, name, phoneNumber, address, comment),
      totalPrice: _getTotalSum(),
      shippingAddress: address ?? 'Не указан',
      paymentMethod: deliveryMethodString,
      phone: phoneNumber ?? 'Не указан',
      timeOrder: DateTime.now(),
    );

    await _sendOrderToTelegram(order.details);
    await OrderService.sendOrderToDatabase(order);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SuccessOrderPage(orderNumber: orderNum)),
    );
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
