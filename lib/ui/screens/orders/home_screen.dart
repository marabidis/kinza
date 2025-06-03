import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/models/product.dart';
import 'package:flutter_kinza/models/CatalogFood.dart';
import 'package:flutter_kinza/services/api_client.dart';

import 'package:flutter_kinza/ui/widgets/horizontal_menu.dart';
import 'package:flutter_kinza/ui/widgets/cart/floating_cart_button.dart';
import 'package:flutter_kinza/ui/widgets/foodCatalog.dart'; // твой путь!
import 'package:flutter_kinza/ui/screens/cart/cart_screen.dart';
import 'package:flutter_kinza/ui/screens/orders/product/product_detail_widget.dart';
import 'package:flutter_kinza/ui/screens/orders/product/glass_sheet_wrapper.dart';

const double _ITEM_HEIGHT = 145.0;

class HomeScreen extends StatefulWidget {
  final ApiClient apiClient;

  const HomeScreen({Key? key, required this.apiClient}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<void> _initFuture;
  late Box<CartItem> _cartBox;
  late CatalogFoodRepository _foodRepo;
  final ScrollController _scrollCtl = ScrollController();

  List<Product> _products = [];
  Map<String, int> _indexMap = {};
  String? _activeCategory;
  bool _isLoading = true;

  final List<String> _categories = [
    'Пицца',
    'Блюда на мангале',
    'Хачапури',
    'К блюду',
  ];

  // ← Новый флаг для скролла по кнопке
  bool _isCategoryScrolling = false;

  @override
  void initState() {
    super.initState();
    _foodRepo = CatalogFoodRepository(widget.apiClient);
    _scrollCtl.addListener(_onScroll);
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    _cartBox = await Hive.openBox<CartItem>('cartBox');

    // загрузка каталога
    final temp = <Product>[];
    for (final cat in _categories) {
      temp.addAll(await _foodRepo.fetchFoodItemsByCategory(cat));
    }
    final uniq = <String, Product>{};
    for (final p in temp) {
      uniq[p.id.toString()] = p;
    }
    _products = uniq.values.toList()
      ..sort((a, b) => _categories
          .indexOf(a.category)
          .compareTo(_categories.indexOf(b.category)));

    _activeCategory = _categories.first;
    for (var i = 0; i < _products.length; i++) {
      // Важно: запомнить только первое вхождение каждой категории!
      _indexMap.putIfAbsent(_products[i].category, () => i);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _scrollCtl.removeListener(_onScroll);
    _scrollCtl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isCategoryScrolling) return;

    final offset = _scrollCtl.offset;
    for (final entry in _indexMap.entries) {
      final start = entry.value * _ITEM_HEIGHT;
      if (offset >= start && offset < start + _ITEM_HEIGHT) {
        if (_activeCategory != entry.key) {
          setState(() => _activeCategory = entry.key);
        }
        break;
      }
    }
  }

  void _onCategoryTap(String cat) {
    final idx = _indexMap[cat];
    if (idx == null) return;

    // Считаем максимальный scroll extent, чтобы не выходить за пределы
    double target = idx * _ITEM_HEIGHT;
    double maxScroll = _scrollCtl.hasClients
        ? _scrollCtl.position.maxScrollExtent
        : (_products.length - 1) * _ITEM_HEIGHT;
    if (target > maxScroll) target = maxScroll;

    _isCategoryScrolling = true;

    _scrollCtl
        .animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    )
        .then((_) {
      // Даем небольшой буфер, чтобы гарантировать, что scroll завершился
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _isCategoryScrolling = false;
      });
    });

    setState(() => _activeCategory = cat);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snap) {
        final theme = Theme.of(context);
        final topInset = MediaQuery.of(context).padding.top;
        final menuTop = topInset + 10;
        final contentTop = menuTop + 38 + 8;

        // Скелетоны-карточки, пока грузим
        if (snap.connectionState != ConnectionState.done || _isLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: contentTop),
                  child: ListView.builder(
                    itemCount: 8,
                    padding: const EdgeInsets.only(bottom: 60),
                    itemBuilder: (_, __) =>
                        const CatalogItemWidget(isSkeleton: true),
                  ),
                ),
                // стекло под меню
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        height: contentTop,
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withOpacity(.22)
                            : Colors.white.withOpacity(.18),
                      ),
                    ),
                  ),
                ),
                // меню
                Positioned(
                  top: menuTop,
                  left: 10,
                  right: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        height: 38,
                        color: Colors.transparent,
                        child: HorizontalMenu(
                          categories: _categories,
                          activeCategory: _activeCategory,
                          onCategoryChanged: _onCategoryTap,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Основной экран — товары
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          floatingActionButton: _buildFab(),
          body: Stack(
            children: [
              // список товаров
              Padding(
                padding: EdgeInsets.only(top: contentTop),
                child: ListView.builder(
                  controller: _scrollCtl,
                  itemCount: _products.length,
                  padding: const EdgeInsets.only(bottom: 60),
                  itemBuilder: (ctx, i) {
                    final p = _products[i];
                    final inCart = _cartBox.containsKey(p.id.toString());
                    return CatalogItemWidget(
                      product: p,
                      isChecked: inCart,
                      onAddToCart: () => _toggleCart(p),
                      onRemoveFromCart: () => _toggleCart(p),
                      onCardTap: () => _openDetail(p),
                    );
                  },
                ),
              ),
              // стекло под меню
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: contentTop,
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(.22)
                          : Colors.white.withOpacity(.18),
                    ),
                  ),
                ),
              ),
              // меню
              Positioned(
                top: menuTop,
                left: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: 38,
                      color: Colors.transparent,
                      child: HorizontalMenu(
                        categories: _categories,
                        activeCategory: _activeCategory,
                        onCategoryChanged: _onCategoryTap,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFab() {
    final count = _cartBox.values.fold<int>(0, (sum, e) => sum + e.quantity);
    return FloatingCartButton(
      itemCount: count,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CartScreen()),
      ),
    );
  }

  Future<void> _toggleCart(Product p, [int qty = 1]) async {
    final key = p.id.toString();
    if (_cartBox.containsKey(key)) {
      await _cartBox.delete(key);
    } else {
      await _cartBox.put(
        key,
        CartItem(
          id: key,
          title: p.title,
          price: p.price,
          quantity: qty,
          weight: p.weight,
          thumbnailUrl: p.imageUrl?.url,
          isWeightBased: p.isWeightBased ?? false,
          minimumWeight: p.minimumWeight,
        ),
      );
    }
    setState(() {});
  }

  void _openDetail(Product p) {
    final ci = _cartBox.get(p.id.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.22),
      builder: (_) => GlassSheetWrapper(
        child: ProductDetailWidget(
          product: p,
          isInCart: _cartBox.containsKey(p.id.toString()),
          initialQuantity: ci?.quantity ?? 1,
          initialWeight: ci?.weight ?? .4,
          onAddToCart: () => _toggleCart(p),
          onQuantityChanged: (q) => _toggleCart(p),
          onWeightChanged: (w) => _toggleCart(p),
          onCartStateChanged: () => setState(() {}),
          updateCartItem: (ci) => _cartBox.put(ci.id, ci),
          removeCartItem: (id) => _cartBox.delete(id),
          onItemAdded: () {},
        ),
      ),
    );
  }
}
