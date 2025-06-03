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
import 'package:flutter_kinza/theme/app_theme.dart';

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
  final VoidCallback onAddToCart; // HomeScreen._toggleCart
  final VoidCallback onCartStateChanged;
  final bool isInCart;
  final int initialQuantity;
  final double initialWeight;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onItemAdded;
  final Function(CartItem) updateCartItem; // cartBox.put(...)
  final Function(String) removeCartItem;

  @override
  State<ProductDetailWidget> createState() => _ProductDetailWidgetState();
}

/*───────────────────────────────────────────────────────────────────*/
class _ProductDetailWidgetState extends State<ProductDetailWidget> {
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

  /*──────── helpers ───────────────────────────────────────────────*/
  bool get _isWeightBased => widget.product.isWeightBased ?? false;
  double get _unitPrice => widget.product.price.toDouble();
  double get _totalPrice =>
      _isWeightBased ? _unitPrice * _weight * 10 : _unitPrice * _qty;

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

  /*──────── main toggle ───────────────────────────────────────────*/
  void _toggleCartState() {
    HapticFeedback.mediumImpact();

    if (_inCart) {
      // Удаляем
      widget.removeCartItem(widget.product.id.toString());
    } else {
      // Сначала «добавить» через HomeScreen._toggleCart
      widget.onAddToCart(); // теперь позиция точно в box
      // А затем — обновить её правильным qty/weight
      widget.updateCartItem(_currentCartItem());
      widget.onItemAdded();
    }

    setState(() => _inCart = !_inCart);
    widget.onCartStateChanged();
  }

  /*──────── live-обновления qty / weight ──────────────────────────*/
  void _updateQuantity(int v) {
    setState(() => _qty = v);
    widget.onQuantityChanged(v);
    if (_inCart) widget.updateCartItem(_currentCartItem());
  }

  void _updateWeight(double v) {
    setState(() => _weight = v);
    widget.onWeightChanged(v);
    if (_inCart) widget.updateCartItem(_currentCartItem());
  }

  /*──────── UI ───────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final isL = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── фото ──
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
                /* title */
                Text(
                  widget.product.title,
                  style: txt.titleLarge?.copyWith(
                      fontSize: 21, fontWeight: FontWeight.w800, height: 1.18),
                ),

                /* weight */
                if (widget.product.weight != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Вес: ${widget.product.weight} кг',
                      style: txt.bodyMedium?.copyWith(
                        fontSize: 15,
                        color:
                            isL ? const Color(0xFF40464F) : cs.onSurfaceVariant,
                      ),
                    ),
                  ),

                /* min weight */
                if (widget.product.minimumWeight != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Минимальный заказ: ${(widget.product.minimumWeight! * 1000).toInt()} г',
                      style: txt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            isL ? const Color(0xFF52575E) : cs.onSurfaceVariant,
                      ),
                    ),
                  ),

                /* description */
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.product.description ?? 'Описание отсутствует',
                    style: txt.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: isL ? AppTheme.gray700 : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                /* bottom panel */
                _ButtonsBlock(
                  isInCart: _inCart,
                  totalPrice: _totalPrice,
                  onMainButtonTap: _toggleCartState,
                  cartControl: CartItemControl(
                    item: _currentCartItem(),
                    isItemInCart: _inCart,
                    isWeightBased: _isWeightBased,
                    onAddToCart: _toggleCartState, // fallback
                    onQuantityChanged: _updateQuantity,
                    onWeightChanged: _updateWeight,
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

/*───────────────────────────────────────────────────────────────────*/
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

/*───────────────────────────────────────────────────────────────────*/
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface),
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
