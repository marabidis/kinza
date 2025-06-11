import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kinza/core/models/CatalogFood.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/models/product.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/features/cart/presentation/screens/cart_screen.dart';
import 'package:kinza/features/orders/presentation/widgets/glass_sheet_wrapper.dart';
import 'package:kinza/features/orders/presentation/widgets/product_detail_widget.dart';
import 'package:kinza/features/cart/presentation/widgets/floating_cart_button.dart';
import 'package:kinza/shared/widgets/foodCatalog.dart'; // твой путь!
import 'package:kinza/shared/widgets/horizontal_menu.dart';
import 'package:hive_flutter/hive_flutter.dart';

const double _ITEM_HEIGHT = 145.0;
const double _MENU_HEIGHT = 38;
const double _MENU_TOP_MARGIN = 10;
const double _MENU_V_SPACING = 8;

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
  final Map<String, int> _indexMap = {};
  String? _activeCategory;
  bool _isLoading = true;
  String? _error;

  final List<String> _categories = [
    'Пицца',
    'Блюда на мангале',
    'Хачапури',
    'К блюду',
  ];

  bool _isCategoryScrolling = false;

  @override
  void initState() {
    super.initState();
    _foodRepo = CatalogFoodRepository(widget.apiClient);
    _scrollCtl.addListener(_onScroll);
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      _cartBox = await Hive.openBox<CartItem>('cartBox');

      final temp = <Product>[];
      for (final cat in _categories) {
        final foods = await _foodRepo.fetchFoodItemsByCategory(cat);
        temp.addAll(foods);
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
        _indexMap.putIfAbsent(_products[i].category, () => i);
      }
      _error = null;
      setState(() => _isLoading = false);
    } on Object catch (e, st) {
      log('ERROR: ${e.toString()}, stacktrace: $st');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
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
        final menuTop = topInset + _MENU_TOP_MARGIN;
        final contentTop = menuTop + _MENU_HEIGHT + _MENU_V_SPACING;

        if (_error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: $_error'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                        _initFuture = _initialize();
                      });
                    },
                    child: const Text('Повторить попытку'),
                  ),
                ],
              ),
            ),
          );
        }

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
                _buildMenuBackground(theme, contentTop),
                _buildMenuBar(menuTop),
              ],
            ),
          );
        }

        // Теперь рендерим экран с корзиной через ValueListenableBuilder (только здесь!)
        return ValueListenableBuilder<Box<CartItem>>(
          valueListenable: _cartBox.listenable(),
          builder: (context, box, _) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              floatingActionButton: _buildFab(box),
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: contentTop),
                    child: ListView.builder(
                      controller: _scrollCtl,
                      itemCount: _products.length,
                      padding: const EdgeInsets.only(bottom: 60),
                      itemBuilder: (ctx, i) {
                        final p = _products[i];
                        final inCart = box.containsKey(p.id.toString());
                        return CatalogItemWidget(
                          product: p,
                          isChecked: inCart,
                          onAddToCart: () => _toggleCart(p, box),
                          onRemoveFromCart: () => _toggleCart(p, box),
                          onCardTap: () => _openDetail(p, box),
                        );
                      },
                    ),
                  ),
                  _buildMenuBackground(theme, contentTop),
                  _buildMenuBar(menuTop),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuBackground(ThemeData theme, double contentTop) {
    return Positioned(
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
    );
  }

  Widget _buildMenuBar(double menuTop) {
    return Positioned(
      top: menuTop,
      left: 10,
      right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: _MENU_HEIGHT,
            color: Colors.transparent,
            child: HorizontalMenu(
              categories: _categories,
              activeCategory: _activeCategory,
              onCategoryChanged: _onCategoryTap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab(Box<CartItem> box) {
    final count = box.values.fold<int>(0, (sum, e) => sum + e.quantity);
    return FloatingCartButton(
      itemCount: count,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CartScreen()),
      ),
    );
  }

  Future<void> _toggleCart(Product p, Box<CartItem> box, [int qty = 1]) async {
    final key = p.id.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      await box.put(
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
    // Не нужен setState — ValueListenableBuilder обновит UI!
  }

  void _openDetail(Product p, Box<CartItem> box) {
    final ci = box.get(p.id.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.22),
      builder: (_) => GlassSheetWrapper(
        child: ProductDetailWidget(
          product: p,
          isInCart: box.containsKey(p.id.toString()),
          initialQuantity: ci?.quantity ?? 1,
          initialWeight: ci?.weight ?? .4,
          onAddToCart: () => _toggleCart(p, box),
          onQuantityChanged: (q) {
            final key = p.id.toString();
            if (box.containsKey(key)) {
              final existing = box.get(key);
              if (existing != null) {
                box.put(
                  key,
                  existing.copyWith(quantity: q),
                );
              }
            }
          },
          onWeightChanged: (w) {
            final key = p.id.toString();
            if (box.containsKey(key)) {
              final existing = box.get(key);
              if (existing != null) {
                box.put(
                  key,
                  existing.copyWith(weight: w),
                );
              }
            }
          },
          onCartStateChanged: () => setState(() {}),
          updateCartItem: (ci) => box.put(ci.id, ci),
          removeCartItem: (id) => box.delete(id),
          onItemAdded: () {},
        ),
      ),
    );
  }
}
