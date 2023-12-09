import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import '/models/product.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class ProductDetailWidget extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onCartStateChanged;
  final bool isInCart;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onItemAdded;

  ProductDetailWidget({
    required this.product,
    required this.onAddToCart,
    required this.isInCart,
    required this.onCartStateChanged,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.onItemAdded,
  });

  @override
  _ProductDetailWidgetState createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  late bool isInCart;

  @override
  void initState() {
    super.initState();
    isInCart = widget.isInCart;
  }

  void updateCartStatus(bool newStatus) {
    setState(() {
      isInCart = newStatus;
    });
  }

  Widget _buildTextWidget(String text, TextStyle style) {
    return Padding(
      padding: EdgeInsets.only(top: AppConstants.indent),
      child: Text(text, style: style),
    );
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
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.baseRadius),
              child: CachedNetworkImage(
                imageUrl: widget.product.imageUrl?.mediumUrl ??
                    'placeholder_image_url',
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            _buildTextWidget(widget.product.title, AppStyles.titleTextStyle),
            _buildTextWidget("Вес: ${widget.product.weight ?? 'N/A'} кг",
                AppStyles.bodyTextStyle),
            _buildTextWidget(
                widget.product.description ?? 'Описание отсутствует',
                AppStyles.bodyTextStyle),
            SizedBox(height: AppConstants.indent),
            buildButtonsSection(isWeightBased),
          ],
        ),
      ),
    );
  }

  Widget buildButtonsSection(bool isWeightBased) {
    final CartItem cartItem = CartItem(
      id: widget.product.id.toString(),
      title: widget.product.title,
      price: widget.product.price,
      quantity: isWeightBased ? 0 : 1,
      weight: isWeightBased ? widget.product.weight : null,
      thumbnailUrl: widget.product.imageUrl?.url,
      isWeightBased: isWeightBased,
      minimumWeight: isWeightBased ? widget.product.minimumWeight : null,
      unit: isWeightBased ? 'г' : null,
    );

    return Row(
      children: [
        Expanded(
          child: MyButton(
            buttonText: isInCart ? "В корзине" : "В корзину",
            onPressed: () {
              widget.onAddToCart();
              updateCartStatus(
                  true); // Обновляем состояние, когда товар добавлен в корзину
            },
            isChecked: isInCart,
          ),
        ),
        SizedBox(width: AppConstants.marginSmall),
        CartItemControl(
          item: cartItem,
          onQuantityChanged: (quantity) {
            widget.onQuantityChanged(quantity);
            setState(() {
              isInCart = quantity > 0; // Изменено условие на quantity > 0
            });
          },
          onWeightChanged: (weight) {
            widget.onWeightChanged(weight);
            setState(() {
              isInCart = weight > 0.0; // Изменено условие на weight > 0.0
            });
          },
          onAddToCart: widget.onAddToCart,
          isItemInCart: widget.isInCart,
          isWeightBased: isWeightBased,
        ),
      ],
    );
  }
}
