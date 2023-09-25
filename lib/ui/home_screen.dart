import 'package:flutter/material.dart';
import '/ui/horizontal_menu.dart';
import '/models/CatalogFood.dart';
import 'foodCatalog.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/cart_item.dart';
import 'dart:developer';
import 'cart_screen.dart';
import 'floating_cart_button.dart';
import './product_detail_widget.dart';

const _ITEM_HEIGHT = 150.0;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatalogFood nameCategory = CatalogFood(supabase);
  String? activeCategory;
  bool _isLoading = true;
  List<Map<String, dynamic>> _data = [];
  ScrollController _controller = ScrollController();

  bool isItemInCart(Map<String, dynamic> item) {
    return cartBox != null && cartBox!.containsKey(item['id'].toString());
  }

  void _showProductDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) {
        return ProductDetailWidget(
          item: item,
          onAddToCart: () {
            _toggleItemInCart(context, item);
          },
          isInCart: isItemInCart(item), // передайте этот параметр
        );
      },
    );
  }

  Box<CartItem>? cartBox;

  @override
  void initState() {
    super.initState();
    _loadCartData();
    _fetchData();
    _controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    print('Scrolling...');
    int itemIndex = (_controller.offset / _ITEM_HEIGHT).round();
    if (itemIndex >= 0 && itemIndex < _data.length) {
      String currentCategory = _data[itemIndex]['category'];
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

  void _toggleItemInCart(
      BuildContext context, Map<String, dynamic> item) async {
    if (cartBox == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка корзины.')));
      return;
    }

    try {
      if (cartBox!.containsKey(item['id'].toString())) {
        await cartBox!.delete(item['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(microseconds: 200),
            content: Text('${item['name_item']} был удален из корзины!')));
      } else {
        final cartItem = CartItem(
          id: item['id'].toString(),
          title: item['name_item'],
          price: item['price'],
          weight: item['weight']?.toString() ?? "",
          quantity: 1,
          imageUrl: item['imageUrl'], // Добавляем imageUrl
        );
        await cartBox!.put(item['id'].toString(), cartItem);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(microseconds: 200),
            content: Text('${item['name_item']} был добавлен в корзину!')));
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

    var newData = await nameCategory.fetchFoodItemsByCategory('Пицца');
    log('Полученные данные: $newData');

    setState(() {
      _data.addAll(newData);
      if (_data.isNotEmpty) {
        activeCategory = _data[0]['category'];
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
              index =
                  _data.indexWhere((item) => item['category'] == 'Хачапури');
              break;
            case 'Пиццы':
              index = _data.indexWhere((item) => item['category'] == 'Пицца');
              break;
            case 'Блюда на мангале':
              index = _data
                  .indexWhere((item) => item['category'] == 'Блюда на мангале');
              break;
            case 'К блюду':
              index = _data.indexWhere((item) => item['category'] == 'К блюду');
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
      body: ListView.builder(
        controller: _controller,
        itemCount: _data.length,
        itemBuilder: (context, index) {
          var item = _data[index];
          return GestureDetector(
            onTap: () => _showProductDetail(context, item),
            child: CatalogItemWidget(
              blurHash: "blurhash_string_for_this_image",
              price: item['price'],
              description: item['description_item'],
              title: item['name_item'],
              imageUrl: item['imageUrl'],
              category: item['category'],
              mark: item['mark'],
              weight: item['weight'],
              onAddToCart: () => _toggleItemInCart(context, item),
            ),
          );
        },
      ),
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
