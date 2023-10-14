import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import '/models/product.dart'; // Убедитесь, что вы импортировали ваш класс Product

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
  bool isInCart = false;

  @override
  void initState() {
    super.initState();
    isInCart = widget
        .isInCart; // Инициализировать переменную состояния значением из виджета
  }

  @override
  void didUpdateWidget(covariant ProductDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInCart != oldWidget.isInCart) {
      setState(() {
        isInCart = widget
            .isInCart; // Обновить переменную состояния, если свойство виджета изменилось
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeightBased = widget.product.isWeightBased ?? false;
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

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                imageUrl: widget.product.imageUrl?.mediumUrl ??
                    'placeholder_image_url', // Измените эту строку
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.product.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              "Вес: ${widget.product.weight} г",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.product.description ?? '',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    buttonText: isInCart ? "В корзине" : "В корзину",
                    onPressed: () {
                      print('Button pressed');
                      widget.onAddToCart();
                      print('onAddToCart called');
                      widget.onCartStateChanged();
                      print('onCartStateChanged called');
                    },
                    isChecked: isInCart,
                  ),
                ),
                SizedBox(width: 12),
                CartItemControl(
                  item: cartItem,
                  onQuantityChanged: (quantity) {
                    widget.onQuantityChanged(quantity);
                    if (quantity > 1) {
                      setState(() {
                        isInCart = true;
                      });
                    } else {
                      setState(() {
                        isInCart = false;
                      });
                    }
                  },
                  onWeightChanged: widget.onWeightChanged,
                  onAddToCart: widget.onAddToCart,
                  isItemInCart: widget.isInCart,
                  isWeightBased: isWeightBased,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
