// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_kinza/ui/widgets/my_button.dart';
// import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
// import 'package:flutter_kinza/models/cart_item.dart';
// import '/models/product.dart'; // Убедитесь, что вы импортировали ваш класс Product

// class ProductDetailWidget extends StatelessWidget {
//   final Product
//       product; // Изменено с Map<String, dynamic> item на Product product
//   final VoidCallback onAddToCart;
//   final VoidCallback onCartStateChanged;
//   final bool isInCart;
//   final ValueChanged<int> onQuantityChanged;
//   final ValueChanged<double> onWeightChanged;
//   final VoidCallback onItemAdded; // новый аргумент

//   ProductDetailWidget({
//     required this.product, // Изменено с required this.item на required this.product
//     required this.onAddToCart,
//     required this.isInCart,
//     required this.onCartStateChanged,
//     required this.onQuantityChanged,
//     required this.onWeightChanged,
//     required this.onItemAdded, // новый аргумент
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isWeightBased = product.isWeightBased ??
//         false; // Изменено с item['isWeightBased'] на product.isWeightBased
//     final CartItem cartItem = CartItem(
//       id: product.id
//           .toString(), // Изменено с item['id'].toString() на product.id.toString()
//       title: product.title, // Изменено с item['name_item'] на product.title
//       price: product.price, // Изменено с item['price'] на product.price
//       quantity: isWeightBased ? 0 : 1,
//       weight: isWeightBased
//           ? product.weight
//           : null, // Изменено с item['weight'] на product.weight
//       imageUrl: product.imageUrl
//           ?.url, // Изменено с item['imageUrl'] на product.imageUrl?.url
//       isWeightBased: isWeightBased,
//       minimumWeight: isWeightBased
//           ? product.minimumWeight
//           : null, // Изменено с item['minimumWeight'] на product.minimumWeight
//       unit: isWeightBased ? 'г' : null,
//     );

//     return SingleChildScrollView(
//       child: Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20.0),
//               child: CachedNetworkImage(
//                 imageUrl: product.imageUrl?.url ?? 'placeholder_image_url',
//                 placeholder: (context, url) => CircularProgressIndicator(),
//                 errorWidget: (context, url, error) => Icon(Icons.error),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               product.title, // Изменено с item['name_item'] на product.title
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               "Вес: ${product.weight} г", // Изменено с item['weight'] на product.weight
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               product.description ??
//                   '', // Изменено с item['description_item'] на product.description ?? ''
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 16.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: MyButton(
//                     buttonText: isInCart ? "Удалить из корзины" : "В корзину",
//                     onPressed: () {
//                       print('Button pressed');
//                       onAddToCart();
//                       print('onAddToCart called');
//                       onCartStateChanged();
//                       print('onCartStateChanged called');
//                     },
//                     isChecked: isInCart,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 CartItemControl(
//                   item: cartItem,
//                   onQuantityChanged: onQuantityChanged,
//                   onWeightChanged: onWeightChanged,
//                   onAddToCart: onAddToCart, // передаем аргумент onAddToCart
//                   isItemInCart: isInCart, // передаем аргумент isItemInCart
//                   isWeightBased: product.isWeightBased ??
//                       false, // Изменено с item['isWeightBased'] на product.isWeightBased ?? false
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
