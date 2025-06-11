// lib/ui/widgets/catalog_item_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/models/product.dart';
import 'package:flutter_kinza/theme/app_theme.dart';

import 'main_skeleton_container.dart';

class CatalogItemWidget extends StatefulWidget {
  final Product? product;
  final bool isChecked;
  final bool isSkeleton;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;
  final VoidCallback? onCardTap; // ← добавили

  const CatalogItemWidget({
    Key? key,
    this.product,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.onCardTap,
    this.isChecked = false,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  State<CatalogItemWidget> createState() => _CatalogItemWidgetState();
}

class _CatalogItemWidgetState extends State<CatalogItemWidget>
    with TickerProviderStateMixin {
  /* ─── Animations ─────────────────────────────────────────────────── */
  late final AnimationController _plusCtl;

  late final Animation<double> _plusScale;

  // «утопление» карточки
  late final AnimationController _pressCtl;

  bool _isInCart = false;

  @override
  void initState() {
    super.initState();

    _isInCart = widget.isChecked;

    _plusCtl = AnimationController(
      duration: AppTheme.animNormal,
      vsync: this,
    );

    _plusScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _plusCtl, curve: Curves.easeOut));

    // «утопление» карточки
    _pressCtl = AnimationController(
      duration: AppTheme.animFast,
      vsync: this,
      lowerBound: .96,
      upperBound: 1,
      value: 1,
    );
  }

  /* ─── Life-cycle ─────────────────────────────────────────────────── */
  @override
  void didUpdateWidget(covariant CatalogItemWidget old) {
    super.didUpdateWidget(old);
    if (old.isChecked != widget.isChecked) _isInCart = widget.isChecked;
  }

  @override
  void dispose() {
    _plusCtl.dispose();
    _pressCtl.dispose();
    super.dispose();
  }

  /* ─── Helpers ────────────────────────────────────────────────────── */
  void _toggleCart() {
    HapticFeedback.mediumImpact();
    _plusCtl.forward(from: 0);
    setState(() => _isInCart = !_isInCart);
    if (_isInCart) {
      widget.onAddToCart?.call();
    } else {
      widget.onRemoveFromCart?.call();
    }
  }

  /* ─── Skeleton ───────────────────────────────────────────────────── */
  Widget _buildSkeleton() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      decoration: AppTheme.cardDecoration(context),
      child: Row(
        children: [
          MainSkeletonContainer(
            width: 96,
            height: 96,
            radius: AppTheme.imageRadius,
            color: cs.surfaceContainerHighest,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainSkeletonContainer(
                    width: 100,
                    height: 16,
                    radius: 8,
                    margin: const EdgeInsets.only(bottom: 6),
                    color: cs.surfaceContainerHighest,
                  ),
                  MainSkeletonContainer(
                    width: 160,
                    height: 12,
                    radius: 6,
                    margin: const EdgeInsets.only(bottom: 6),
                    color: cs.surfaceContainerHighest,
                  ),
                  MainSkeletonContainer(
                    width: 100,
                    height: 12,
                    radius: 6,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: cs.surfaceContainerHighest,
                  ),
                  Row(
                    children: [
                      MainSkeletonContainer(
                        width: 56,
                        height: 22,
                        radius: 7,
                        color: cs.surfaceContainerHighest,
                      ),
                      const Spacer(),
                      MainSkeletonContainer(
                        width: 28,
                        height: 28,
                        rounded: true,
                        color: cs.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ─── Image ─────────────────────────────────────────────────────── */
  Widget _productImage() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.imageRadius),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.imageRadius),
        child: CachedNetworkImage(
          imageUrl:
              widget.product?.imageUrl?.thumbnailUrl ?? 'placeholder_image_url',
          placeholder: (_, __) => MainSkeletonContainer(
              width: 96,
              height: 96,
              radius: AppTheme.imageRadius,
              color: cs.surfaceContainerHighest),
          errorWidget: (_, __, ___) => const Icon(Icons.error, size: 64),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /* ─── Build ─────────────────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    if (widget.isSkeleton) return _buildSkeleton();

    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final mark = widget.product?.mark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtl.reverse(), // 1 → 0.96
      onTapCancel: () => _pressCtl.forward(), // вернёмся к 1
      onTapUp: (_) {
        HapticFeedback.selectionClick(); // <--- вот сюда добавил вибрацию!
        _pressCtl.forward();
        widget.onCardTap?.call(); // открыть деталь
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_plusCtl, _pressCtl]),
        builder: (context, _) {
          return Transform.scale(
            scale: _pressCtl.value, // утопление
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: AppTheme.cardDecoration(context),
              child: Row(
                children: [
                  _productImage(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* ── Название + иконка ── */
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.product?.title ?? '',
                                  style: txt.titleMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (mark == 'острая')
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Image.asset(
                                    'assets/ostray_perez.png',
                                    width: 21,
                                    height: 21,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product?.description ?? '',
                            style: txt.bodySmall?.copyWith(
                              fontSize: 12.5,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 7),
                                decoration:
                                    AppTheme.priceTagDecoration(context),
                                child: Text(
                                  widget.product != null
                                      ? '${(widget.product!.isWeightBased ?? false) ? "от " : ""}${widget.product!.price}₽'
                                      : '',
                                  style: txt.labelLarge
                                      ?.copyWith(color: cs.onSurface),
                                ),
                              ),
                              const Spacer(),
                              Transform.scale(
                                scale: _plusScale.value,
                                child: IconButton(
                                  icon: Icon(
                                    _isInCart
                                        ? Icons.remove_circle_outline
                                        : Icons.add_circle_outline,
                                    color: _isInCart ? cs.error : cs.primary,
                                  ),
                                  splashRadius: AppTheme.iconButtonSplashRadius,
                                  onPressed: _toggleCart,
                                  tooltip: _isInCart
                                      ? 'Удалить из корзины'
                                      : 'Добавить в корзину',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
