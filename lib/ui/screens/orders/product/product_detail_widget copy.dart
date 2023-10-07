// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_kinza/ui/widgets/my_button.dart';

// class ProductDetailWidget extends StatelessWidget {
//   final Map<String, dynamic> item;
//   final VoidCallback onAddToCart;
//   final VoidCallback onCartStateChanged; // Добавленный обратный вызов
//   final bool isInCart;

//   ProductDetailWidget({
//     required this.item,
//     required this.onAddToCart,
//     required this.isInCart,
//     required this.onCartStateChanged, // Добавьте этот параметр
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Фото товара с округленными углами
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20.0),
//               child: CachedNetworkImage(
//                 imageUrl: item['imageUrl'] ?? 'placeholder_image_url',
//                 placeholder: (context, url) => CircularProgressIndicator(),
//                 errorWidget: (context, url, error) => Icon(Icons.error),
//               ),
//             ),
//             SizedBox(height: 16.0),

//             // Название товара
//             Text(
//               item['name_item'],
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),

//             // Вес
//             Text(
//               "Вес: ${item['weight']} г",
//               style: TextStyle(fontSize: 16),
//             ),

//             SizedBox(height: 8.0),

//             // Описание товара
//             Text(
//               item['description_item'],
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 16.0),

//             // Кнопка добавления в корзину или удаления из неё
//             MyButton(
//               buttonText: isInCart ? "Удалить из корзины" : "В корзину",
//               onPressed: () {
//                 print('Button pressed');
//                 onAddToCart();
//                 print('onAddToCart called');
//                 onCartStateChanged(); // Уведомляем родительский виджет об изменении состояния корзины
//                 print('onCartStateChanged called');
//               },
//               isChecked: isInCart,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
