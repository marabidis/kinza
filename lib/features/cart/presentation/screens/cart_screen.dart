import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/services/order_helpers.dart';
import 'package:kinza/features/address/presentation/screens/address_list_screen.dart';
import 'package:kinza/features/cart/presentation/screens/checkout_screen.dart';
import 'package:kinza/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:kinza/features/cart/presentation/widgets/empty_cart_screen.dart';
import 'package:kinza/shared/widgets/animated_price.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Box<CartItem> cartBox;
  Address? _selectedAddress;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  int _lastTotalSum = 0;
  bool _isLoading = true;

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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: _buildAppBar(cs, txt, dark),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          itemCount: 5,
          itemBuilder: (_, __) => const CartItemWidget(isSkeleton: true),
        ),
      );
    }

    final isEmpty = cartBox.isEmpty;
    final totalSum = getTotalSum(cartBox);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(cs, txt, dark),
      body: isEmpty ? const EmptyCartScreen() : _buildCartList(cs, txt),
      bottomNavigationBar: isEmpty ? null : _buildBottomBar(totalSum, cs, txt),
    );
  }

  AppBar _buildAppBar(ColorScheme cs, TextTheme txt, bool dark) => AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(color: cs.onSurface),
    title: Text(
      'Ваш заказ',
      style: txt.titleLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    systemOverlayStyle:
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color:
              dark
                  ? Colors.black.withOpacity(.30)
                  : Colors.white.withOpacity(.25),
        ),
      ),
    ),
  );

  Widget _buildCartList(ColorScheme cs, TextTheme txt) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          const SizedBox(height: 18),
          // Блок выбора адреса
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GestureDetector(
              onTap: _pickAddress,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _selectedAddress == null
                              ? Text(
                                'Добавить адрес доставки',
                                style: txt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAddress!.typeLabel,
                                    style: txt.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedAddress!.fullLine,
                                    style: txt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                    Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Список товаров
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: cartBox.length,
              itemBuilder: (context, index, anim) {
                final item = cartBox.getAt(index)!;
                final isLast = index == cartBox.length - 1;
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
                        onDelete: () => _deleteItemFromCart(index),
                        onQuantityChanged:
                            (q) => _updateCartItem(
                              index,
                              item.copyWith(quantity: q),
                            ),
                        onWeightChanged:
                            (w) => _updateCartItem(
                              index,
                              item.copyWith(weight: w),
                            ),
                        isLastItem: isLast,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickAddress() async {
    final chosen = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (_) => const AddressListScreen()),
    );
    if (chosen != null) {
      setState(() => _selectedAddress = chosen);
    }
  }

  Widget _buildBottomBar(int totalSum, ColorScheme cs, TextTheme txt) {
    // Анимация суммы
    if (_lastTotalSum != totalSum) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _lastTotalSum = totalSum);
      });
    }

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
        child: ElevatedButton(
          // Кнопка всегда активна
          onPressed: _openCheckout,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Оформить на ',
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
          ),
        ),
      ),
    );
  }

  void _openCheckout() {
    final totalSum = getTotalSum(cartBox);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CheckoutScreen(
              total: totalSum,
              initialAddress: _selectedAddress,
            ),
      ),
    );
  }

  void _deleteItemFromCart(int index) {
    final item = cartBox.getAt(index)!;
    cartBox.deleteAt(index);
    _listKey.currentState?.removeItem(
      index,
      (ctx, anim) => _buildCartListItem(item, index, anim),
      duration: const Duration(milliseconds: 300),
    );
    setState(() {});
  }

  Widget _buildCartListItem(CartItem item, int idx, Animation<double> anim) {
    final cs = Theme.of(context).colorScheme;
    final isLast = idx == cartBox.length - 1;
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
            onQuantityChanged:
                (q) => _updateCartItem(idx, item.copyWith(quantity: q)),
            onWeightChanged:
                (w) => _updateCartItem(idx, item.copyWith(weight: w)),
            isLastItem: isLast,
          ),
        ),
      ),
    );
  }

  void _updateCartItem(int index, CartItem updatedItem) {
    cartBox.putAt(index, updatedItem);
    setState(() {});
  }
}
