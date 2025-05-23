import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/models/product.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/services/api_client.dart';
import 'package:flutter_kinza/ui/widgets/cart/floating_cart_button.dart';
import 'package:flutter_kinza/ui/screens/cart/cart_screen.dart';
import 'package:flutter_kinza/ui/widgets/horizontal_menu.dart';
import 'package:flutter_kinza/services/utils.dart';
import 'package:flutter_kinza/ui/screens/orders/product/product_detail_widget.dart';
import '../../../models/CatalogFood.dart';
import '../../widgets/foodCatalog.dart';

const _ITEM_HEIGHT = 145.0;

class HomeScreen extends StatefulWidget {
  final ApiClient apiClient;

  HomeScreen({required this.apiClient});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CatalogFoodRepository nameCategory;
  late ValueNotifier<String?> activeCategoryNotifier;
  bool _isLoading = true;
  List<Product> _data = [];
  ScrollController _controller = ScrollController();
  Map<String, int> categoryIndexes = {};

  Box<CartItem>? cartBox;

  @override
  void initState() {
    super.initState();
    nameCategory = CatalogFoodRepository(widget.apiClient);
    activeCategoryNotifier = ValueNotifier<String?>(null);
    _loadCartData();
    _fetchData();
    _controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      activeCategoryNotifier.addListener(_syncMenuWithCategory);
    });
  }

  void _syncMenuWithCategory() {}

  void _loadCartData() async {
    try {
      cartBox = await Hive.openBox<CartItem>('cartBox');
      setState(() {});
    } catch (e) {
      print("Ошибка при работе с Hive: $e");
    }
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Product> newData =
          await nameCategory.fetchFoodItemsByCategory('Пицца');
      if (newData.isNotEmpty) {
        List<Map<String, dynamic>> dataToSort = newData.map((product) {
          return {'category': product.category, 'product': product};
        }).toList();
        List<Map<String, dynamic>> sortedData = sortCategories(dataToSort);
        setState(() {
          _data = sortedData.map((item) => item['product'] as Product).toList();
          activeCategoryNotifier.value = _data[0].category;
          _isLoading = false;
        });
        _createCategoryIndexMap();
      } else {
        print("Нет данных для загрузки");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Ошибка при загрузке данных: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createCategoryIndexMap() {
    categoryIndexes.clear();
    for (int i = 0; i < _data.length; i++) {
      String category = _data[i].category;
      if (!categoryIndexes.containsKey(category)) {
        categoryIndexes[category] = i;
      }
    }
  }

  void _onScroll() {
    double offset = _controller.offset;
    double itemHeight = _ITEM_HEIGHT;
    for (var entry in categoryIndexes.entries) {
      int index = entry.value;
      double itemOffset = index * itemHeight;
      if (offset >= itemOffset && offset < itemOffset + itemHeight) {
        if (activeCategoryNotifier.value != entry.key) {
          activeCategoryNotifier.value = entry.key;
        }
        break;
      }
    }
  }

  void scrollToCategory(String category) {
    int? index = categoryIndexes[category];
    if (index != null) {
      _controller.animateTo(
        index * _ITEM_HEIGHT,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    activeCategoryNotifier.removeListener(_syncMenuWithCategory);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HorizontalMenu(
        onCategoryChanged: scrollToCategory,
        activeCategoryNotifier: activeCategoryNotifier,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.only(bottom: 60),
        itemBuilder: (context, index) =>
            const CatalogItemWidget(isSkeleton: true),
      );
    }
    if (cartBox == null) return Center(child: CircularProgressIndicator());

    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: cartBox!.listenable(),
      builder: (context, box, _) {
        return ListView.builder(
          controller: _controller,
          itemCount: _data.length,
          padding: const EdgeInsets.only(bottom: 60),
          itemBuilder: (context, index) {
            var product = _data[index];
            return GestureDetector(
              onTap: () => _showProductDetail(context, product),
              child: CatalogItemWidget(
                product: product,
                isChecked: isItemInCart(product),
                onAddToCart: () => _toggleItemInCart(context, product),
                onRemoveFromCart: () => _toggleItemInCart(context, product),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    if (cartBox == null) return Container();
    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: cartBox!.listenable(),
      builder: (context, box, _) {
        return FloatingCartButton(
          itemCount: box.values
              .fold(0, (previousValue, item) => previousValue + item.quantity),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartScreen()));
          },
        );
      },
    );
  }

  bool isItemInCart(Product product) {
    return cartBox != null && cartBox!.containsKey(product.id.toString());
  }

  void _toggleItemInCart(BuildContext context, Product product,
      [int quantity = 1]) async {
    if (cartBox == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка корзины.')));
      return;
    }

    if (cartBox!.containsKey(product.id.toString())) {
      await cartBox!.delete(product.id.toString());
    } else {
      final cartItem = CartItem(
        id: product.id.toString(),
        title: product.title,
        price: product.price,
        weight: product.weight,
        quantity: quantity,
        thumbnailUrl: product.imageUrl?.url,
        isWeightBased: product.isWeightBased ?? false,
        minimumWeight: product.minimumWeight,
      );
      await cartBox!.put(product.id.toString(), cartItem);
    }
    setState(() {});
  }

  void _showProductDetail(BuildContext context, Product product) {
    CartItem? cartItem = cartBox?.get(product.id.toString());
    int currentQuantity = cartItem?.quantity ?? 1;
    double currentWeight = cartItem?.weight ?? 0.4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) {
        return ProductDetailWidget(
          product: product,
          onAddToCart: () => _toggleItemInCart(context, product),
          isInCart: isItemInCart(product),
          onCartStateChanged: () => setState(() {}),
          onQuantityChanged: (quantity) {
            if (!isItemInCart(product)) {
              _toggleItemInCart(context, product, quantity);
            }
          },
          onWeightChanged: (weight) {
            if (!isItemInCart(product)) {
              _toggleItemInCart(context, product);
            }
          },
          onItemAdded: () {},
          initialQuantity: currentQuantity,
          initialWeight: currentWeight,
          updateCartItem: (updatedItem) =>
              _updateCartItem(context, updatedItem),
          removeCartItem: (itemId) => _removeCartItem(context, itemId),
        );
      },
    );
  }

  void _updateCartItem(BuildContext context, CartItem updatedItem) {
    if (cartBox == null) return;

    int index = cartBox!.values
        .toList()
        .indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      cartBox!.putAt(index, updatedItem);
    }
  }

  void _removeCartItem(BuildContext context, String itemId) {
    if (cartBox == null) return;

    cartBox!.delete(itemId);
  }
}
