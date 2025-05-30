import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_kinza/models/product.dart';
import 'main_skeleton_container.dart';
import 'package:flutter_kinza/theme/app_theme.dart';

class CatalogItemWidget extends StatefulWidget {
  final Product? product;
  final bool isChecked;
  final bool isSkeleton;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;

  const CatalogItemWidget({
    Key? key,
    this.product,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.isChecked = false,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  State<CatalogItemWidget> createState() => _CatalogItemWidgetState();
}

class _CatalogItemWidgetState extends State<CatalogItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _plusScale;
  late Animation<double> _cardScale;
  late bool _isInCart;

  @override
  void initState() {
    super.initState();

    _isInCart = widget.isChecked;

    _controller = AnimationController(
      duration: AppTheme.animNormal,
      vsync: this,
    );

    _plusScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _cardScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.04, end: 1), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant CatalogItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      setState(() {
        _isInCart = widget.isChecked;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSkeleton() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: EdgeInsets.all(AppTheme.cardPadding),
      decoration: AppTheme.cardDecoration(context),
      child: Row(
        children: [
          MainSkeletonContainer(
            width: 96, height: 96, radius: AppTheme.imageRadius,
            // 👇 Передавай цвет скелетона, если MainSkeletonContainer поддерживает
            color: colorScheme.surfaceVariant,
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
                    color: colorScheme.surfaceVariant,
                  ),
                  MainSkeletonContainer(
                    width: 160,
                    height: 12,
                    radius: 6,
                    margin: const EdgeInsets.only(bottom: 6),
                    color: colorScheme.surfaceVariant,
                  ),
                  MainSkeletonContainer(
                    width: 100,
                    height: 12,
                    radius: 6,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: colorScheme.surfaceVariant,
                  ),
                  Row(
                    children: [
                      MainSkeletonContainer(
                        width: 56,
                        height: 22,
                        radius: 7,
                        color: colorScheme.surfaceVariant,
                      ),
                      const Spacer(),
                      MainSkeletonContainer(
                        width: 28,
                        height: 28,
                        rounded: true,
                        color: colorScheme.surfaceVariant,
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

  Widget _buildPhotoWithMark() {
    final mark = widget.product?.mark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildImage(),
        if (mark == 'острая')
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/ostray_perez.png',
              width: 60,
              height: 60,
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.imageRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
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
          placeholder: (context, url) => MainSkeletonContainer(
              width: 96,
              height: 96,
              radius: AppTheme.imageRadius,
              color: colorScheme.surfaceVariant),
          errorWidget: (context, url, error) =>
              const Icon(Icons.error, size: 64),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _handlePlusMinusTap() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0);
    setState(() {
      _isInCart = !_isInCart;
    });
    if (_isInCart) {
      widget.onAddToCart?.call();
    } else {
      widget.onRemoveFromCart?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSkeleton) {
      return _buildSkeleton();
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScale.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.cardDecoration(context),
            child: Row(
              children: [
                _buildPhotoWithMark(),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product?.title ?? "",
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product?.description ?? "",
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
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
                              decoration: AppTheme.priceTagDecoration(context),
                              child: Text(
                                widget.product != null
                                    ? '${widget.product!.isWeightBased == true ? "от " : ""}${widget.product!.price}₽'
                                    : '',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
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
                                  color: _isInCart
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                ),
                                splashRadius: AppTheme.iconButtonSplashRadius,
                                onPressed: _handlePlusMinusTap,
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
    );
  }
}
