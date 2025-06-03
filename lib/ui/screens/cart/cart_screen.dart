// lib/ui/screens/cart/cart_screen.dart
import 'dart:ui'; // ← для BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_widget.dart';
import 'package:flutter_kinza/ui/widgets/cart/empty_cart_screen.dart';
import 'package:flutter_kinza/ui/widgets/foodCatalog.dart';
import 'package:hive/hive.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import '../orders/success_order_page.dart';
import 'package:flutter_kinza/services/order_service.dart';
import 'package:flutter_kinza/ui/widgets/cart/delivery_info_bottom_sheet.dart';
import '/forms/OrderForm.dart';
import 'package:flutter_kinza/services/order_helpers.dart';
import 'package:flutter_kinza/models/delivery_method.dart';
import 'package:flutter_kinza/services/telegram_service.dart';
import 'package:flutter_kinza/ui/widgets/animated_price.dart';

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
  int _lastTotalSum = 0;

  bool _isLoading = true; // добавлено

  @override
  void initState() {
    super.initState();
    _initCart();
  }

  Future<void> _initCart() async {
    cartBox = await Hive.openBox<CartItem>('cartBox');
    _lastTotalSum = getTotalSum(cartBox);
    setState(() => _isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      _lastTotalSum = getTotalSum(cartBox);
    }
  }

  /*──────────────────────────────────────────────────────────────────────*/

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Скелетон на время загрузки корзины
    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: cs.onSurface),
          title: Text(
            'Ваш заказ',
            style: textTheme.titleLarge
                ?.copyWith(color: cs.onBackground, fontWeight: FontWeight.w700),
          ),
          systemOverlayStyle:
              dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: dark
                    ? Colors.black.withOpacity(.30)
                    : Colors.white.withOpacity(.25),
              ),
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          itemCount: 5,
          itemBuilder: (_, __) => const CatalogItemWidget(isSkeleton: true),
        ),
      );
    }

    final isEmpty = cartBox.isEmpty;
    final totalSum = getTotalSum(cartBox);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // ← убираем фон
        iconTheme: IconThemeData(color: cs.onSurface),
        title: Text(
          'Ваш заказ',
          style: textTheme.titleLarge
              ?.copyWith(color: cs.onBackground, fontWeight: FontWeight.w700),
        ),
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        flexibleSpace: ClipRect(
          // ← стеклянный слой
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: dark
                  ? Colors.black.withOpacity(.30)
                  : Colors.white.withOpacity(.25),
            ),
          ),
        ),
      ),
      body: isEmpty ? EmptyCartScreen() : _buildCartList(cs),
      bottomNavigationBar: _buildBottomNavigationBar(totalSum, cs, textTheme),
    );
  }

  /*──────────────────────────────────────────────────────────────────────*/
  /*                           CART LIST                                 */
  /*──────────────────────────────────────────────────────────────────────*/

  Widget _buildCartList(ColorScheme cs) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: cartBox.length,
              itemBuilder: (context, index, animation) {
                final item = cartBox.getAt(index);
                final isLast = index == cartBox.length - 1;
                return item != null
                    ? _buildCartItem(item, index, animation, isLast, cs)
                    : const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: OrderForm(
              key: _orderFormKey,
              deliveryMethodNotifier: _deliveryMethodNotifier,
              updateDelivery: (m) =>
                  setState(() => _deliveryMethodNotifier.value = m),
              onSubmit: (m, name, phone, addr, comm) {
                if (_orderFormKey.currentState!.validate()) {
                  _processOrder(m, name, phone, addr, comm);
                }
              },
              totalPrice: getTotalSum(cartBox),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int idx, Animation<double> anim,
      bool isLast, ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: SizeTransition(
        sizeFactor: anim,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: CartItemWidget(
            item: item,
            onDelete: () => _deleteItemFromCart(idx),
            onQuantityChanged: (q) =>
                _updateCartItem(idx, item.copyWith(quantity: q)),
            onWeightChanged: (w) =>
                _updateCartItem(idx, item.copyWith(weight: w)),
            isLastItem: isLast,
          ),
        ),
      ),
    );
  }

  /*──────────────────────────────────────────────────────────────────────*/
  /*                        BOTTOM  BAR                                   */
  /*──────────────────────────────────────────────────────────────────────*/

  Widget _buildBottomNavigationBar(
      int totalSum, ColorScheme cs, TextTheme txt) {
    final isEmpty = cartBox.isEmpty;

    // для анимации суммы
    if (_lastTotalSum != totalSum) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _lastTotalSum = totalSum);
      });
    }

    if (isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
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
                          : 'Доставка — 100 ₽\nДо бесплатной: ${800 - totalSum} ₽',
                      style: txt.bodySmall?.copyWith(
                        color: totalSum >= 800 ? cs.primary : cs.error,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: cs.primary),
                    onPressed: () => _showDeliveryDetails(context),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
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
                          final data =
                              _orderFormKey.currentState!.getFormData();
                          _processOrder(
                            data['method'],
                            data['name'],
                            data['phoneNumber'],
                            data['address'],
                            data['comment'],
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: _isProcessing ||
                          (_deliveryMethodNotifier.value ==
                                  DeliveryMethod.courier &&
                              totalSum < 800)
                      ? cs.outline.withOpacity(0.4)
                      : cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : (_deliveryMethodNotifier.value == DeliveryMethod.pickup ||
                            totalSum >= 800)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Оформить заказ на ',
                                style: txt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimary,
                                ),
                              ),
                              AnimatedPrice(
                                value: totalSum.toDouble(),
                                style: txt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Добавьте товаров ещё на ${800 - totalSum} ₽',
                            style: txt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimary,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*──────────────────────────────────────────────────────────────────────*/
  /*                         HELPERS                                      */
  /*──────────────────────────────────────────────────────────────────────*/

  void _scrollToOrderForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showDeliveryDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const DeliveryInfoBottomSheet(),
    );
  }

  void _deleteItemFromCart(int index) {
    final item = cartBox.getAt(index);
    if (item != null) {
      cartBox.deleteAt(index);
      _listKey.currentState?.removeItem(
        index,
        (ctx, anim) => _buildCartItem(item, index, anim,
            index == cartBox.length - 1, Theme.of(ctx).colorScheme),
        duration: const Duration(milliseconds: 300),
      );
    }
    setState(() {});
  }

  void _updateCartItem(int index, CartItem updatedItem) {
    cartBox.putAt(index, updatedItem);
    setState(() {});
  }

  void _processOrder(DeliveryMethod m, String? name, String? phone,
      String? addr, String? comm) async {
    if (!_orderFormKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    final orderNum = await incrementOrderNumber();
    final totalSum = getTotalSum(cartBox);

    // --- Формируем текст заказа для Telegram ---
    final orderDetails = generateOrderDetailsString(
      orderNum,
      m,
      name,
      phone,
      addr,
      comm,
      cartBox,
      totalSum,
      m,
    );

    // --- СОЗДАЁМ объект Order для Strapi ---
    final order = Order(
      orderNumber: orderNum,
      details: orderDetails,
      totalPrice: totalSum,
      shippingAddress: addr ?? '',
      paymentMethod: m == DeliveryMethod.courier ? 'Курьер' : 'Самовывоз',
      phone: phone ?? '',
      timeOrder: DateTime.now(),
    );

    // --- Отправляем заказ в Strapi ---
    try {
      final ok = await OrderService.sendOrderToDatabase(order);
      if (!ok) {
        debugPrint("Ошибка при отправке заказа в Strapi!");
        // Здесь можно показать SnackBar или что-то ещё пользователю
      }
    } catch (e) {
      debugPrint("Exception при отправке заказа в Strapi: $e");
    }

    // --- Отправляем заказ в Telegram ---
    try {
      await sendOrderToTelegram(orderDetails);
    } catch (e) {
      debugPrint("Ошибка при отправке заказа в Telegram: $e");
      // Здесь можно показать SnackBar, если нужно
    }

    // ... логика перехода на SuccessOrderPage …
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessOrderPage(orderNumber: orderNum),
      ),
    );
    setState(() => _isProcessing = false);
  }
}
