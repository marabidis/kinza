// lib/features/cart/presentation/screens/cart_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/models/delivery_method.dart';
import 'package:kinza/core/services/address_service.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ValueNotifier<DeliveryMethod> _deliveryMethodNotifier =
      ValueNotifier<DeliveryMethod>(DeliveryMethod.courier);

  int _lastTotalSum = 0;
  bool _isLoading = true;

  /// Загруженные адреса и выбранный адрес
  late Future<List<Address>> _addressesFuture;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _initCart();
    _addressesFuture = AddressService().fetchForCurrentUser();
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

    // Скелетон во время инициализации Hive
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
      body: isEmpty ? const EmptyCartScreen() : _buildCartList(cs),
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

  Widget _buildCartList(ColorScheme cs) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          const SizedBox(height: 18),

          // ─── Блок выбора адреса ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildAddressHeader(cs, Theme.of(context).textTheme),
          ),
          const SizedBox(height: 18),

          // ─── Список товаров ──────────────────────────
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
                return _buildCartItem(item, index, anim, isLast, cs);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddressHeader(ColorScheme cs, TextTheme txt) {
    final hasAddress = _selectedAddress != null;
    return GestureDetector(
      onTap: _pickAddress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child:
                  hasAddress
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAddress!.typeLabel,
                            style: txt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _selectedAddress!.fullLine,
                            style: txt.bodySmall?.copyWith(color: cs.outline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                      : Text(
                        'Выбрать адрес доставки',
                        style: txt.bodyLarge?.copyWith(color: cs.primary),
                      ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAddress() async {
    final chosen = await Navigator.push<Address?>(
      context,
      MaterialPageRoute(builder: (_) => const AddressListScreen()),
    );
    if (chosen != null) {
      setState(() => _selectedAddress = chosen);
    }
  }

  Widget _buildCartItem(
    CartItem item,
    int idx,
    Animation<double> anim,
    bool isLast,
    ColorScheme cs,
  ) {
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

  Widget _buildBottomBar(int totalSum, ColorScheme cs, TextTheme txt) {
    if (_lastTotalSum != totalSum) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _lastTotalSum = totalSum);
      });
    }

    final canCheckout =
        _deliveryMethodNotifier.value == DeliveryMethod.pickup ||
        (_deliveryMethodNotifier.value == DeliveryMethod.courier &&
            totalSum >= 800);

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
          onPressed: canCheckout ? _openCheckout : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor:
                canCheckout ? cs.primary : cs.outline.withOpacity(0.4),
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
      MaterialPageRoute(builder: (_) => CheckoutScreen(total: totalSum)),
    );
  }

  void _deleteItemFromCart(int index) {
    final item = cartBox.getAt(index);
    if (item != null) {
      cartBox.deleteAt(index);
      _listKey.currentState?.removeItem(
        index,
        (ctx, anim) => _buildCartItem(
          item,
          index,
          anim,
          index == cartBox.length - 1,
          Theme.of(ctx).colorScheme,
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
    setState(() {});
  }

  void _updateCartItem(int index, CartItem updatedItem) {
    cartBox.putAt(index, updatedItem);
    setState(() {});
  }
}
