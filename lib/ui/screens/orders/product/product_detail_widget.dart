import 'package:flutter/material.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:flutter_kinza/models/product.dart';

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

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  late bool isInCart;
  late int currentQuantity;
  late double currentWeight;

  @override
  void initState() {
    super.initState();
    isInCart = widget.isInCart;
    currentQuantity = widget.initialQuantity;
    currentWeight = widget.initialWeight;
  }

  void updateCartStatus(bool newStatus) {
    setState(() {
      isInCart = newStatus;
    });
  }

  void updateCartItemInCart(CartItem updatedItem) {
    widget.updateCartItem(updatedItem);
  }

  void removeItemFromCart(String itemId) {
    widget.removeCartItem(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeightBased = widget.product.isWeightBased ?? false;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildTextWidget(widget.product.title, AppStyles.titleTextStyle),
            _buildTextWidget("Вес: ${widget.product.weight ?? 'N/A'} кг",
                AppStyles.bodyTextStyle),
            _buildTextWidget(
                widget.product.description ?? 'Описание отсутствует',
                AppStyles.bodyTextStyle),
            SizedBox(height: AppConstants.indent),
            _buildButtonsSection(isWeightBased),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1, // Соотношение сторон изображения
            child: Container(
              color:
                  Colors.grey[200], // Цвет фона, пока изображение не загружено
            ),
          ),
          Positioned.fill(
            child: Image.network(
              widget.product.imageUrl?.mediumUrl ?? 'placeholder_image_url',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWidget(String text, TextStyle style) {
    return Padding(
      padding: EdgeInsets.only(top: AppConstants.indent),
      child: Text(text, style: style),
    );
  }

  Widget _buildButtonsSection(bool isWeightBased) {
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

    return Row(
      children: [
        Expanded(
          child: MyButton(
            buttonText: isInCart ? "В корзине" : "В корзину",
            onPressed: () {
              widget.onAddToCart();
              updateCartStatus(true);
            },
            isChecked: isInCart,
          ),
        ),
        SizedBox(width: AppConstants.marginSmall),
        CartItemControl(
          item: cartItem,
          onQuantityChanged: (quantity) {
            setState(() => currentQuantity = quantity);
            widget.onQuantityChanged(quantity);
            if (quantity > 0) {
              updateCartItemInCart(cartItem.copyWith(quantity: quantity));
            } else {
              removeItemFromCart(cartItem.id);
            }
            updateCartStatus(quantity > 0);
          },
          onWeightChanged: (weight) {
            setState(() => currentWeight = weight);
            widget.onWeightChanged(weight);
            if (weight > 0.0) {
              updateCartItemInCart(cartItem.copyWith(weight: weight));
            } else {
              removeItemFromCart(cartItem.id);
            }
            updateCartStatus(weight > 0.0);
          },
          onAddToCart: widget.onAddToCart,
          isItemInCart: isInCart,
          isWeightBased: isWeightBased,
        ),
      ],
    );
  }
}
