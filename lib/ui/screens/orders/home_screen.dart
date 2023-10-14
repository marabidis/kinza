import 'package:flutter/material.dart';
import '../../widgets/horizontal_menu.dart';
import '/models/CatalogFood.dart';
import '../../widgets/foodCatalog.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/cart_item.dart';
import 'dart:developer';
import '../cart/cart_screen.dart';
import '../../widgets/cart/floating_cart_button.dart';
import 'product/product_detail_widget.dart';
import '/services/api_client.dart';
import '/models/product.dart'; // Импортирование модели продукта
import '/services/utils.dart'; // замените 'path_to' на путь к вашему файлу utils.dart

const _ITEM_HEIGHT = 153.0;

class HomeScreen extends StatefulWidget {
  final ApiClient apiClient;

  HomeScreen({required this.apiClient});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CatalogFoodRepository nameCategory; // Changed to late final
  String? activeCategory;
  bool _isLoading = true;
  List<Product> _data =
      []; // Изменено с List<Map<String, dynamic>> на List<Product>

  ScrollController _controller = ScrollController();

  bool isItemInCart(Product product) {
    return cartBox != null && cartBox!.containsKey(product.id.toString());
  }

  void _showProductDetail(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) {
        return ProductDetailWidget(
          product:
              product, // Теперь это правильно, если в ProductDetailWidget параметр назван product
          onAddToCart: () {
            _toggleItemInCart(context, product); // Изменено на product
          },
          isInCart: isItemInCart(product), // Изменено на product
          onCartStateChanged: () {
            setState(
                () {}); // Просто вызываем setState для перестройки виджетов
          },
          onQuantityChanged: (quantity) {
            if (!isItemInCart(product)) {
              // Изменено на product
              _toggleItemInCart(
                  context, product, quantity); // Изменено на product
            } // Дополнительная логика, если требуется
          },
          onWeightChanged: (weight) {
            if (!isItemInCart(product)) {
              // Изменено на product
              _toggleItemInCart(context, product); // Изменено на product
            }
            // Дополнительная логика, если требуется
          },
          onItemAdded: () {
            // Здесь ваш код, который должен быть выполнен, когда элемент добавлен
          },
        );
      },
    );
  }

  Box<CartItem>? cartBox;

  @override
  void initState() {
    super.initState();
    nameCategory = CatalogFoodRepository(widget.apiClient);
    print('HomeScreen initState called'); // Добавьте эту строку
    _loadCartData();
    _fetchData();
    _controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    print('Scrolling...');
    int itemIndex = (_controller.offset / _ITEM_HEIGHT).round();
    if (itemIndex >= 0 && itemIndex < _data.length) {
      String currentCategory = _data[itemIndex]
          .category; // Обновлено с _data[itemIndex]['category'] на _data[itemIndex].category
      if (currentCategory != activeCategory) {
        setState(() {
          activeCategory = currentCategory;
        });
      }
    }
  }

  _loadCartData() async {
    try {
      cartBox = await Hive.openBox<CartItem>('cartBox');
    } catch (e) {
      print("Ошибка при работе с Hive: $e");
    }
  }

  void _toggleItemInCart(BuildContext context, Product product,
      [int quantity = 1]) async {
    if (cartBox == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка корзины.')));

      // Обновите состояние, чтобы вызвать перестроение виджета
      setState(() {});
      return;
    }

    try {
      if (cartBox!.containsKey(product.id.toString())) {
        await cartBox!.delete(product.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(microseconds: 600),
            content: Text('${product.title} был удален из корзины!')));
      } else {
        final cartItem = CartItem(
          id: product.id.toString(),
          title: product.title,
          price: product.price,
          weight: product.weight, // обновлено
          quantity: quantity, // Используйте переданное количество
          thumbnailUrl: product.imageUrl?.url, // обновлено
          isWeightBased: product.isWeightBased ?? false, // обновлено
          minimumWeight: product.minimumWeight, // обновлено
          unit:
              'unit', // Необходимо обновить на соответствующее значение из product, если оно есть
        );

        await cartBox!.put(product.id.toString(), cartItem);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(microseconds: 1000),
            content: Text('${product.title} был добавлен в корзину!')));
      }
    } catch (e) {
      print('Ошибка при работе с коробкой Hive: $e');
    }
  }

  _fetchData() async {
    log("Запрашиваем данные");

    setState(() {
      _isLoading = true;
    });

    List<Product> newData = await nameCategory
        .fetchFoodItemsByCategory('Пицца'); // Уточнено: List<Product>
    log('Полученные данные: $newData');

    // Сортировка данных
    List<Map<String, dynamic>> dataToSort = newData.map((product) {
      return {
        'category': product.category,
        'product': product,
      };
    }).toList();
    List<Map<String, dynamic>> sortedData = sortCategories(dataToSort);

    setState(() {
      _data.addAll(
          sortedData.map((item) => item['product'] as Product).toList());
      if (_data.isNotEmpty) {
        activeCategory = _data[0]
            .category; // Обновлено с _data[0]['category'] на _data[0].category
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HorizontalMenu(
        onCategoryChanged: (category) {
          int? index;
          switch (category) {
            case 'Хачапури':
              index = _data.indexWhere((item) => item.category == 'Хачапури');
              break;
            case 'Пиццы':
              index = _data.indexWhere((item) => item.category == 'Пицца');
              break;
            case 'Блюда на мангале':
              index = _data
                  .indexWhere((item) => item.category == 'Блюда на мангале');
              break;
            case 'К блюду':
              index = _data.indexWhere((item) => item.category == 'К блюду');
              break;
          }

          if (index != null && index != -1) {
            _controller.animateTo(
              index * _ITEM_HEIGHT,
              duration: Duration(milliseconds: 500),
              curve: Curves.decelerate,
            );
          }
        },
      ),
      body: cartBox != null
          ? ValueListenableBuilder(
              valueListenable: cartBox!.listenable(),
              builder: (context, Box<CartItem> box, _) {
                return ListView.builder(
                  controller: _controller,
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    var product = _data[
                        index]; // изменили имя переменной на product для ясности
                    return GestureDetector(
                      onTap: () => _showProductDetail(context, product),
                      child: CatalogItemWidget(
                        product:
                            product, // Передайте объект Product в CatalogItemWidget
                        isChecked: isItemInCart(product),
                        onAddToCart: () => _toggleItemInCart(context, product),
                      ),
                    );
                  },
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: cartBox != null
          ? ValueListenableBuilder(
              valueListenable: cartBox!.listenable(),
              builder: (context, Box<CartItem> box, _) {
                return FloatingCartButton(
                  itemCount: box.values.fold(0,
                      (previousValue, item) => previousValue + item.quantity),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                );
              },
            )
          : Container(),
    );
  }
}
