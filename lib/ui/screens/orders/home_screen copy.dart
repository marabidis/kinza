// import 'package:flutter/material.dart';
// import '../../widgets/horizontal_menu.dart';
// import '../../../models/CatalogFood.dart';
// import '../../widgets/foodCatalog.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../../../models/cart_item.dart';
// import 'dart:developer';
// import '../cart/cart_screen.dart';
// import '../../widgets/cart/floating_cart_button.dart';
// import 'product/product_detail_widget.dart';
// import '../../../services/api_client.dart';
// import '../../../models/product.dart';
// import '../../../services/utils.dart'; // Убедитесь, что sortCategories доступна из этого файла

// const _ITEM_HEIGHT = 145.0;

// class HomeScreen extends StatefulWidget {
//   final ApiClient apiClient;

//   HomeScreen({required this.apiClient});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late final CatalogFoodRepository nameCategory;
//   String? activeCategory;
//   bool _isLoading = true;
//   List<Product> _data = [];
//   ScrollController _controller = ScrollController();
//   GlobalKey<HorizontalMenuState> menuKey = GlobalKey();
//   double _lastOffset = 0; // Для отслеживания последнего смещения
//   bool _isFirstScroll = true; // Для проверки первой прокрутки

//   bool isItemInCart(Product product) {
//     return cartBox != null && cartBox!.containsKey(product.id.toString());
//   }

//   void _showProductDetail(BuildContext context, Product product) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
//       ),
//       builder: (context) {
//         return ProductDetailWidget(
//           product: product,
//           onAddToCart: () {
//             _toggleItemInCart(context, product);
//           },
//           isInCart: isItemInCart(product),
//           onCartStateChanged: () {
//             setState(() {});
//           },
//           onQuantityChanged: (quantity) {
//             if (!isItemInCart(product)) {
//               _toggleItemInCart(context, product, quantity);
//             }
//           },
//           onWeightChanged: (weight) {
//             if (!isItemInCart(product)) {
//               _toggleItemInCart(context, product);
//             }
//           },
//           onItemAdded: () {
//             // Код, выполняемый при добавлении элемента
//           },
//         );
//       },
//     );
//   }

//   Box<CartItem>? cartBox;

//   @override
//   void initState() {
//     super.initState();
//     nameCategory = CatalogFoodRepository(widget.apiClient);
//     _controller.addListener(_scrollListener);
//     _loadCartData();
//     _fetchData();
//   }

//   void _scrollListener() {
//     int itemIndex = (_controller.offset / _ITEM_HEIGHT).round();
//     if (itemIndex >= 0 && itemIndex < _data.length) {
//       String currentCategory = _data[itemIndex].category;
//       if (currentCategory != activeCategory) {
//         bool isScrollingDown = _controller.offset > _lastOffset;

//         _lastOffset = _controller.offset;

//         if (_isFirstScroll) {
//           _isFirstScroll = false;
//           return;
//         }

//         if (isScrollingDown || _controller.offset == 0) {
//           setState(() {
//             activeCategory = currentCategory;
//           });
//           menuKey.currentState?.setActiveCategory(currentCategory);
//         }
//       }
//     }
//   }

//   _loadCartData() async {
//     try {
//       cartBox = await Hive.openBox<CartItem>('cartBox');
//     } catch (e) {
//       print("Ошибка при работе с Hive: $e");
//     }
//   }

//   void _toggleItemInCart(BuildContext context, Product product,
//       [int quantity = 1]) async {
//     if (cartBox == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Ошибка корзины.')));

//       // Обновите состояние, чтобы вызвать перестроение виджета
//       setState(() {});
//       return;
//     }

//     try {
//       if (cartBox!.containsKey(product.id.toString())) {
//         await cartBox!.delete(product.id.toString());
//       } else {
//         final cartItem = CartItem(
//           id: product.id.toString(),
//           title: product.title,
//           price: product.price,
//           weight: product.weight, // обновлено
//           quantity: quantity, // Используйте переданное количество
//           thumbnailUrl: product.imageUrl?.url, // обновлено
//           isWeightBased: product.isWeightBased ?? false, // обновлено
//           minimumWeight: product.minimumWeight, // обновлено
//           unit:
//               'unit', // Необходимо обновить на соответствующее значение из product, если оно есть
//         );

//         await cartBox!.put(product.id.toString(), cartItem);
//       }
//     } catch (e) {
//       print('Ошибка при работе с коробкой Hive: $e');
//     }
//   }

//   _fetchData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       List<Product> newData =
//           await nameCategory.fetchFoodItemsByCategory('Пицца');
//       if (newData.isNotEmpty) {
//         List<Map<String, dynamic>> dataToSort = newData.map((product) {
//           return {'category': product.category, 'product': product};
//         }).toList();

//         List<Map<String, dynamic>> sortedData = sortCategories(dataToSort);
//         setState(() {
//           _data = sortedData.map((item) => item['product'] as Product).toList();
//           activeCategory = _data[0].category;
//           _isLoading = false;
//         });
//       } else {
//         print("Нет данных для загрузки");
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Ошибка при загрузке данных: $e");
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: HorizontalMenu(
//         key: menuKey,
//         onCategoryChanged: (category) {
//           int? index;
//           switch (category) {
//             case 'Пицца':
//               index = _data.indexWhere((item) => item.category == 'Пицца');
//               break;
//             case 'Блюда на мангале':
//               index = _data
//                   .indexWhere((item) => item.category == 'Блюда на мангале');
//               break;
//             case 'Хачапури':
//               index = _data.indexWhere((item) => item.category == 'Хачапури');
//               break;
//             case 'К блюду':
//               index = _data.indexWhere((item) => item.category == 'К блюду');
//               break;
//           }

//           if (index != null && index != -1) {
//             _controller.animateTo(index * _ITEM_HEIGHT,
//                 duration: Duration(milliseconds: 500),
//                 curve: Curves.decelerate);
//           }
//         },
//         activeCategory: activeCategory ?? 'Пицца',
//       ),
//       body: _buildBody(),
//       floatingActionButton: _buildFloatingActionButton(),
//     );
//   }

//   Widget _buildBody() {
//     return cartBox != null
//         ? ValueListenableBuilder<Box<CartItem>>(
//             valueListenable: cartBox!.listenable(),
//             builder: (context, box, _) {
//               return NotificationListener<ScrollNotification>(
//                 onNotification: (ScrollNotification notification) {
//                   if (notification.metrics.pixels >= 0 &&
//                       notification.metrics.pixels <=
//                           notification.metrics.maxScrollExtent) {
//                     // Дополнительная проверка, чтобы избежать отрицательного индекса
//                     var categoryIndex =
//                         (notification.metrics.pixels / _ITEM_HEIGHT).floor();
//                     // ... остальная логика ...
//                   }
//                   return true;
//                 },
//                 child: ListView.builder(
//                   controller: _controller,
//                   itemCount: _data.length,
//                   itemBuilder: (context, index) {
//                     var product = _data[index];
//                     return GestureDetector(
//                       onTap: () => _showProductDetail(context, product),
//                       child: CatalogItemWidget(
//                         product: product,
//                         isChecked: isItemInCart(product),
//                         onAddToCart: () => _toggleItemInCart(context, product),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           )
//         : Center(child: CircularProgressIndicator());
//   }

//   Widget _buildFloatingActionButton() {
//     return cartBox != null
//         ? ValueListenableBuilder<Box<CartItem>>(
//             valueListenable: cartBox!.listenable(),
//             builder: (context, box, _) {
//               return FloatingCartButton(
//                 itemCount: box.values.fold(
//                     0, (previousValue, item) => previousValue + item.quantity),
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => CartScreen()));
//                 },
//               );
//             },
//           )
//         : Container();
//   }
// }
