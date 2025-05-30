// lib/ui/screens/orders/product/product_detail_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/models/product.dart';
import 'package:flutter_kinza/ui/widgets/animated_price.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:shimmer/shimmer.dart';

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

/*──────────────────────────────────────────────────────────────────────────*/

class _ProductDetailWidgetState extends State<ProductDetailWidget>
    with SingleTickerProviderStateMixin {
  late bool _inCart;
  late int _qty;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _inCart = widget.isInCart;
    _qty = widget.initialQuantity;
    _weight = widget.initialWeight;
  }

  /*──────── helpers ────────*/
  bool get _isWeightBased => widget.product.isWeightBased ?? false;
  double get _unitPrice => widget.product.price.toDouble();
  double get _totalPrice =>
      _isWeightBased ? _unitPrice * _weight * 10 : _unitPrice * _qty.toDouble();

  CartItem _currentCartItem() => CartItem(
        id: widget.product.id.toString(),
        title: widget.product.title,
        price: widget.product.price,
        quantity: _qty,
        weight: _weight,
        thumbnailUrl: widget.product.imageUrl?.url,
        isWeightBased: _isWeightBased,
        minimumWeight: widget.product.minimumWeight,
      );

  void _toggleCartState() {
    HapticFeedback.mediumImpact();
    if (_inCart) {
      widget.removeCartItem(widget.product.id.toString());
    } else {
      widget.updateCartItem(_currentCartItem());
      widget.onAddToCart();
      widget.onItemAdded();
    }
    setState(() => _inCart = !_inCart);
    widget.onCartStateChanged();
  }

  /*──────── build ────────*/

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: _HeaderImage(product: widget.product),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                ),
                if (widget.product.weight != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Вес: ${widget.product.weight} кг',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.product.description ?? 'Описание отсутствует',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                _ButtonsBlock(
                  isInCart: _inCart,
                  totalPrice: _totalPrice,
                  cartControl: CartItemControl(
                    item: _currentCartItem(),
                    isItemInCart: _inCart,
                    isWeightBased: _isWeightBased,
                    onAddToCart: () {
                      widget.updateCartItem(_currentCartItem());
                      if (!_inCart) widget.onItemAdded();
                      setState(() => _inCart = true);
                    },
                    onQuantityChanged: (v) {
                      setState(() => _qty = v);
                      widget.onQuantityChanged(v);
                    },
                    onWeightChanged: (v) {
                      setState(() => _weight = v);
                      widget.onWeightChanged(v);
                    },
                  ),
                  onMainButtonTap: _toggleCartState,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*──────────────────────────────────────────────────────────────────────────*/

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final hash = product.blurHash.isNotEmpty ? product.blurHash : null;
    final url =
        product.imageUrl?.mediumUrl ?? 'https://via.placeholder.com/600';
    final cs = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            if (hash != null) Positioned.fill(child: BlurHash(hash: hash)),
            Shimmer.fromColors(
              baseColor: cs.surfaceVariant,
              highlightColor: cs.surface,
              child: Container(color: cs.surfaceVariant),
            ),
          ],
        ),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded,
            size: 64, color: Colors.grey),
      ),
    );
  }
}

/*──────── панель с кнопкой/ценой (без внутреннего blur) ───*/

class _ButtonsBlock extends StatelessWidget {
  const _ButtonsBlock({
    required this.isInCart,
    required this.totalPrice,
    required this.cartControl,
    required this.onMainButtonTap,
  });

  final bool isInCart;
  final double totalPrice;
  final Widget cartControl;
  final VoidCallback onMainButtonTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 13),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withOpacity(.35)
            : Colors.white.withOpacity(.30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedPrice(
              value: totalPrice,
              showPrefix: false,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          cartControl,
          const SizedBox(width: 12),
          SizedBox(
            width: 124,
            child: MyButton(
              buttonText: isInCart ? 'В корзине' : 'В корзину',
              isChecked: isInCart,
              onPressed: onMainButtonTap,
              height: 44,
              borderRadius: 11,
              backgroundColor:
                  isInCart ? cs.surface : cs.primary.withOpacity(.90),
              textColor: isInCart ? cs.onSurface.withOpacity(.7) : cs.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
