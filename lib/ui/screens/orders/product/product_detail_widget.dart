import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:flutter_kinza/models/product.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:flutter_kinza/ui/widgets/animated_price.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailWidget extends StatefulWidget {
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

  ProductDetailWidget({
    required this.product,
    required this.onAddToCart,
    required this.isInCart,
    this.initialQuantity = 1,
    this.initialWeight = 0.4,
    required this.onCartStateChanged,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.onItemAdded,
    required this.updateCartItem,
    required this.removeCartItem,
  });

  @override
  _ProductDetailWidgetState createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget>
    with SingleTickerProviderStateMixin {
  late bool isInCart;
  late int currentQuantity;
  late double currentWeight;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    isInCart = widget.isInCart;
    currentQuantity = widget.initialQuantity;
    currentWeight = widget.initialWeight;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  void updateCartStatus(bool newStatus) {
    setState(() {
      isInCart = newStatus;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeightBased = widget.product.isWeightBased ?? false;
    final double price = widget.product.price.toDouble();
    final double totalPrice = isWeightBased
        ? (price * currentWeight * 10)
        : (price * currentQuantity.toDouble());

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото на всю ширину экрана (без паддингов и скруглений)
            _buildImage(context),
            const SizedBox(height: 22),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: AppStyles.titleTextStyle.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.product.weight != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Вес: ${widget.product.weight} кг",
                        style: AppStyles.bodyTextStyle.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF67768C),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      widget.product.description ?? 'Описание отсутствует',
                      style: AppStyles.bodyTextStyle.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF67768C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildButtonsSection(isWeightBased, totalPrice),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final String? blurHash =
        (widget.product.blurHash.isNotEmpty) ? widget.product.blurHash : null;

    // Фото на всю ширину экрана (никаких borderRadius)
    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
        imageUrl: widget.product.imageUrl?.mediumUrl ??
            'https://via.placeholder.com/600',
        fit: BoxFit.cover,
        placeholder: (context, url) => Stack(
          fit: StackFit.expand,
          children: [
            if (blurHash != null)
              Positioned.fill(child: BlurHash(hash: blurHash)),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.white),
            ),
          ],
        ),
        errorWidget: (_, __, ___) => const Icon(
          Icons.broken_image_rounded,
          size: 64,
          color: Colors.grey,
        ),
        fadeInDuration: const Duration(milliseconds: 250),
        fadeInCurve: Curves.easeOut,
      ),
    );
  }

  Widget _buildButtonsSection(bool isWeightBased, double totalPrice) {
    final CartItem cartItem = CartItem(
      id: widget.product.id.toString(),
      title: widget.product.title,
      price: widget.product.price,
      quantity: currentQuantity,
      weight: currentWeight,
      thumbnailUrl: widget.product.imageUrl?.url,
      isWeightBased: isWeightBased,
      minimumWeight: widget.product.minimumWeight,
    );

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 13),
      child: Row(
        children: [
          Expanded(
            child: MyButton(
              buttonText: isInCart ? "В корзине" : "В корзину",
              onPressed: () {
                if (isInCart) {
                  // Удалить из корзины
                  widget.removeCartItem(widget.product.id.toString());
                  updateCartStatus(false);
                } else {
                  // Добавить в корзину
                  final CartItem updatedCartItem = CartItem(
                    id: widget.product.id.toString(),
                    title: widget.product.title,
                    price: widget.product.price,
                    quantity: currentQuantity,
                    weight: currentWeight,
                    thumbnailUrl: widget.product.imageUrl?.url,
                    isWeightBased: widget.product.isWeightBased ?? false,
                    minimumWeight: widget.product.minimumWeight,
                  );
                  widget.updateCartItem(updatedCartItem);
                  widget.onAddToCart();
                  widget.onItemAdded();
                  updateCartStatus(true);
                }
              },
              isChecked: isInCart,
              height: 44,
              borderRadius: 11,
              backgroundColor:
                  isInCart ? const Color(0xFFECECEC) : const Color(0xFFFFD600),
              textColor: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: BoxConstraints(minWidth: 140, maxWidth: 200),
            child: Row(
              children: [
                CartItemControl(
                  item: cartItem,
                  onQuantityChanged: (quantity) {
                    setState(() => currentQuantity = quantity);
                    widget.onQuantityChanged(quantity);
                  },
                  onWeightChanged: (weight) {
                    setState(() => currentWeight = weight);
                    widget.onWeightChanged(weight);
                  },
                  onAddToCart: () {
                    final CartItem updatedCartItem = CartItem(
                      id: widget.product.id.toString(),
                      title: widget.product.title,
                      price: widget.product.price,
                      quantity: currentQuantity,
                      weight: currentWeight,
                      thumbnailUrl: widget.product.imageUrl?.url,
                      isWeightBased: widget.product.isWeightBased ?? false,
                      minimumWeight: widget.product.minimumWeight,
                    );
                    widget.updateCartItem(updatedCartItem);
                    updateCartStatus(true);
                  },
                  isItemInCart: isInCart,
                  isWeightBased: isWeightBased,
                ),
                const SizedBox(width: 14),
                AnimatedPrice(
                  value: totalPrice,
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                  showPrefix: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
