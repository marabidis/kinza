// lib/ui/screens/home/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_kinza/ui/screens/orders/product/glass_sheet_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import 'package:flutter_kinza/theme/app_colors.dart';
import 'package:flutter_kinza/theme/app_styles.dart';

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

  const HomeScreen({super.key, required this.apiClient});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CatalogFoodRepository _foodRepo;

  final List<String> _categories = [
    'Пицца',
    'Блюда на мангале',
    'Хачапури',
    'К блюду',
  ];

  String? activeCategory;
  bool _isLoading = true;

  final List<Product> _data = [];
  final ScrollController _controller = ScrollController();
  final Map<String, int> _categoryIndexes = {};

  Box<CartItem>? cartBox;

  @override
  void initState() {
    super.initState();
    _foodRepo = CatalogFoodRepository(widget.apiClient);
    _loadCartData();
    _fetchData();
    _controller.addListener(_onScroll);
  }

  // ---------------- data -----------------

  Future<void> _loadCartData() async {
    cartBox = await Hive.openBox<CartItem>('cartBox');
    if (mounted) setState(() {});
  }

  /// Загрузка каталога без дублей
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final tmp = <Product>[];

      // грузим все категории
      for (final cat in _categories) {
        final items = await _foodRepo.fetchFoodItemsByCategory(cat);
        tmp.addAll(items);
      }

      // убираем повторы по id
      final uniq = <String, Product>{};
      for (final p in tmp) {
        final key = p.id?.toString() ?? '${p.title}_${p.category}';
        uniq.putIfAbsent(key, () => p);
      }

      _data
        ..clear()
        ..addAll(uniq.values);

      // сортировка по порядку категорий
      _data.sort(
        (a, b) => _categories
            .indexOf(a.category)
            .compareTo(_categories.indexOf(b.category)),
      );

      activeCategory = _categories.first;
      _createCategoryIndexMap();
    } catch (e, st) {
      debugPrint('Ошибка при загрузке каталога: $e\n$st');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _createCategoryIndexMap() {
    _categoryIndexes.clear();
    for (var i = 0; i < _data.length; i++) {
      _categoryIndexes.putIfAbsent(_data[i].category, () => i);
    }
  }

  // ------------- scrolling / sync -------------

  void _onScroll() {
    final offset = _controller.offset;
    for (final entry in _categoryIndexes.entries) {
      final start = entry.value * _ITEM_HEIGHT;
      if (offset >= start && offset < start + _ITEM_HEIGHT) {
        if (activeCategory != entry.key) {
          setState(() => activeCategory = entry.key);
        }
        break;
      }
    }
  }

  void _scrollToCategory(String category) {
    final idx = _categoryIndexes[category];
    if (idx == null) return;

    _controller.animateTo(
      idx * _ITEM_HEIGHT,
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );

    setState(() => activeCategory = category);
  }

  // ------------- build -------------

  @override
  Widget build(BuildContext context) {
    final menuPaddingTop = MediaQuery.of(context).padding.top + 10;
    final contentTopPadding = 38 + menuPaddingTop + 8;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: _buildFab(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: contentTopPadding),
            child: _buildBody(),
          ),

          // стекло под статус-баром / меню
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: contentTopPadding,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
              ),
            ),
          ),

          // стеклянное «горизонтальное меню»
          Positioned(
            top: menuPaddingTop,
            left: 0,
            right: 0,
            child: _buildGlassMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMenu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.transparent,
          child: HorizontalMenu(
            categories: _categories,
            activeCategory: activeCategory,
            onCategoryChanged: _scrollToCategory,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.only(bottom: 60),
        itemBuilder: (_, __) => const CatalogItemWidget(isSkeleton: true),
      );
    }

    if (cartBox == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = _data;

    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: cartBox!.listenable(),
      builder: (_, __, ___) {
        return ListView.builder(
          controller: _controller,
          itemCount: products.length,
          padding: const EdgeInsets.only(bottom: 60),
          itemBuilder: (_, i) {
            final p = products[i];
            return GestureDetector(
              onTap: () => _showProductDetail(p),
              child: CatalogItemWidget(
                product: p,
                isChecked: isItemInCart(p),
                onAddToCart: () => _toggleItemInCart(p),
                onRemoveFromCart: () => _toggleItemInCart(p),
              ),
            );
          },
        );
      },
    );
  }

  // ------------- cart helpers -------------

  Widget _buildFab() {
    if (cartBox == null) return const SizedBox();
    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: cartBox!.listenable(),
      builder: (_, box, __) {
        final count = box.values.fold<int>(0, (prev, e) => prev + e.quantity);
        return FloatingCartButton(
          itemCount: count,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => CartScreen())),
        );
      },
    );
  }

  bool isItemInCart(Product p) =>
      cartBox != null && cartBox!.containsKey(p.id.toString());

  Future<void> _toggleItemInCart(Product p, [int quantity = 1]) async {
    if (cartBox == null) return;
    final key = p.id.toString();
    if (cartBox!.containsKey(key)) {
      await cartBox!.delete(key);
    } else {
      await cartBox!.put(
        key,
        CartItem(
          id: key,
          title: p.title,
          price: p.price,
          weight: p.weight,
          quantity: quantity,
          thumbnailUrl: p.imageUrl?.url,
          isWeightBased: p.isWeightBased ?? false,
          minimumWeight: p.minimumWeight,
        ),
      );
    }
    setState(() {});
  }

  /* ----- главное: открываем стеклянный bottom-sheet ----- */
  void _showProductDetail(Product p) {
    final cartItem = cartBox?.get(p.id.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // лист прозрачен
      barrierColor: Colors.transparent, // фон тоже
      isScrollControlled: true,
      builder: (_) => GlassSheetWrapper(
        // обёртка со blur
        child: ProductDetailWidget(
          product: p,
          isInCart: isItemInCart(p),
          initialQuantity: cartItem?.quantity ?? 1,
          initialWeight: cartItem?.weight ?? .4,
          onAddToCart: () => _toggleItemInCart(p),
          onQuantityChanged: (q) => _toggleItemInCart(p, q),
          onWeightChanged: (_) => _toggleItemInCart(p),
          onCartStateChanged: () => setState(() {}),
          updateCartItem: (ci) => cartBox?.put(ci.id, ci),
          removeCartItem: (id) => cartBox?.delete(id),
          onItemAdded: () {},
        ),
      ),
    );
  }
}
