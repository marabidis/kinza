import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:flutter_kinza/models/cart_item.dart';

class ProductDetailWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAddToCart;
  final VoidCallback onCartStateChanged;
  final bool isInCart;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onItemAdded; // новый аргумент

  ProductDetailWidget({
    required this.item,
    required this.onAddToCart,
    required this.isInCart,
    required this.onCartStateChanged,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.onItemAdded, // новый аргумент
  });

  @override
  Widget build(BuildContext context) {
    final bool isWeightBased = item['isWeightBased'];
    final CartItem cartItem = CartItem(
      id: item['id'].toString(),
      title: item['name_item'],
      price: item['price'],
      quantity: isWeightBased ? 0 : 1,
      weight: isWeightBased ? item['weight'] : null,
      imageUrl: item['imageUrl'],
      isWeightBased: isWeightBased,
      minimumWeight: isWeightBased ? item['minimumWeight'] : null,
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
                imageUrl: item['imageUrl'] ?? 'placeholder_image_url',
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              item['name_item'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              "Вес: ${item['weight']} г",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              item['description_item'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    buttonText: isInCart ? "Удалить из корзины" : "В корзину",
                    onPressed: () {
                      print('Button pressed');
                      onAddToCart();
                      print('onAddToCart called');
                      onCartStateChanged();
                      print('onCartStateChanged called');
                    },
                    isChecked: isInCart,
                  ),
                ),
                SizedBox(width: 12),
                CartItemControl(
                  item: cartItem,
                  onQuantityChanged: onQuantityChanged,
                  onWeightChanged: onWeightChanged,
                  onAddToCart: onAddToCart, // передаем аргумент onAddToCart
                  isItemInCart: isInCart, // передаем аргумент isItemInCart
                  isWeightBased: item['isWeightBased'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
