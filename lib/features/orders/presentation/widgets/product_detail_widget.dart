import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/models/ingredient_option.dart';
import 'package:kinza/core/models/product.dart' show Product;
import 'package:kinza/features/cart/presentation/widgets/cart_item_control.dart';
import 'package:kinza/features/orders/presentation/widgets/glass_sheet_wrapper.dart';
import 'package:kinza/features/orders/presentation/widgets/ingredient_customize_sheet.dart';
import 'package:kinza/shared/widgets/animated_price.dart';
import 'package:kinza/shared/widgets/my_button.dart';
import 'package:kinza/shared/widgets/shimmer.dart';

class ProductDetailWidget extends StatefulWidget {
  const ProductDetailWidget({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCartStateChanged,
    required this.isInCart,
    required this.initialQuantity,
    required this.initialWeight,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.onItemAdded,
    required this.updateCartItem,
    required this.removeCartItem,
  });

  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onCartStateChanged;
  final bool isInCart;
  final int initialQuantity;
  final double initialWeight;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onItemAdded;
  final Function(CartItem) updateCartItem;
  final Function(String) removeCartItem;

  @override
  State<ProductDetailWidget> createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  late bool _inCart;
  late int _qty;
  late double _weight;

  int _extraPrice = 0;
  List<IngredientOption> _selected = [];

  @override
  void initState() {
    super.initState();
    _inCart = widget.isInCart;
    _qty = widget.initialQuantity;
    _weight = widget.initialWeight;
  }

  bool get _isWeightBased => widget.product.isWeightBased ?? false;
  double get _unitPrice => widget.product.price.toDouble();
  double get _totalPrice =>
      (_isWeightBased ? _unitPrice * _weight * 10 : _unitPrice * _qty) +
      _extraPrice;

  CartItem _currentCartItem() => CartItem(
        id: widget.product.id.toString(),
        title: widget.product.title,
        price: (_unitPrice + _extraPrice).toInt(),
        quantity: _qty,
        weight: _weight,
        thumbnailUrl: widget.product.imageUrl?.url,
        isWeightBased: _isWeightBased,
        minimumWeight: widget.product.minimumWeight,
      );

  void _addToCartIfFirstTime() {
    if (!_inCart) {
      widget.onAddToCart();
      widget.updateCartItem(_currentCartItem());
      widget.onItemAdded();
      setState(() => _inCart = true);
      widget.onCartStateChanged();
    }
  }

  void _toggleCartState() {
    HapticFeedback.mediumImpact();
    if (_inCart) {
      widget.removeCartItem(widget.product.id.toString());
    } else {
      widget.onAddToCart();
      widget.updateCartItem(_currentCartItem());
      widget.onItemAdded();
    }
    setState(() => _inCart = !_inCart);
    widget.onCartStateChanged();
  }

  void _updateQuantity(int v) {
    setState(() => _qty = v);
    widget.onQuantityChanged(v);

    if (v > 0) {
      !_inCart
          ? _addToCartIfFirstTime()
          : widget.updateCartItem(_currentCartItem());
    }
  }

  void _updateWeight(double v) {
    setState(() => _weight = v);
    widget.onWeightChanged(v);

    if (v > 0) {
      !_inCart
          ? _addToCartIfFirstTime()
          : widget.updateCartItem(_currentCartItem());
    }
  }

  Future<void> _openCustomizeSheet() async {
    final result = await showModalBottomSheet<List<IngredientOption>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => GlassSheetWrapper(
        child: IngredientCustomizeSheet(
          options: widget.product.ingredientOptions,
          initiallySelected: _selected,
          sheetTitle: widget.product.title,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selected = result;
        _extraPrice = _selected.fold<int>(
          0,
          (sum, o) => sum + (o.canDouble ? o.doublePrice : o.addPrice),
        );
      });
      if (_inCart) widget.updateCartItem(_currentCartItem());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final baseOptions =
        widget.product.ingredientOptions.where((o) => o.isDefault).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderImage(product: widget.product),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: txt.titleLarge?.copyWith(height: 1.18),
                ),
                if (widget.product.weight != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Вес: ${widget.product.weight} кг',
                      style: txt.bodyMedium?.copyWith(
                        color: isLight ? cs.onSurface : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (widget.product.minimumWeight != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Минимальный заказ: ${(widget.product.minimumWeight! * 1000).toInt()} г',
                      style: txt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isLight
                            ? cs.onSurface.withOpacity(0.8)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.product.description,
                    style: txt.bodyMedium?.copyWith(
                      color: isLight
                          ? cs.onSurface.withOpacity(0.9)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (baseOptions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Состав:',
                    style: txt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: baseOptions
                        .map((o) => Chip(
                              label: Text(o.ingredient.name),
                              backgroundColor: cs.surfaceContainerHighest,
                              labelStyle: txt.bodySmall?.copyWith(
                                color: cs.onSurface,
                              ),
                            ))
                        .toList(),
                  ),
                ],
                if (widget.product.ingredientOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: InkWell(
                      onTap: _openCustomizeSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Сделать вкуснее',
                            style: txt.bodyLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: cs.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedPrice(
                          value: _totalPrice,
                          showPrefix: false,
                          style: txt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CartItemControl(
                        item: _currentCartItem(),
                        isItemInCart: _inCart,
                        isWeightBased: _isWeightBased,
                        onAddToCart: _toggleCartState,
                        onQuantityChanged: _updateQuantity,
                        onWeightChanged: _updateWeight,
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 124,
                        child: MyButton(
                          buttonText: _inCart ? 'В корзине' : 'В корзину',
                          isChecked: _inCart,
                          onPressed: _toggleCartState,
                          height: 44,
                          borderRadius: 11,
                          backgroundColor: _inCart
                              ? cs.surface
                              : cs.primary.withOpacity(.90),
                          textColor: _inCart
                              ? cs.onSurface.withOpacity(.7)
                              : cs.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final hash = product.blurHash.isNotEmpty ? product.blurHash : null;
    final url =
        product.imageUrl?.mediumUrl ?? 'https://via.placeholder.com/600';

    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => hash != null
            ? SizedBox.expand(child: BlurHash(hash: hash))
            : const Shimmer(size: Size(double.infinity, double.maxFinite)),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded,
            size: 64, color: Colors.grey),
      ),
    );
  }
}
