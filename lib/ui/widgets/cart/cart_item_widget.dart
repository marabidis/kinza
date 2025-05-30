import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/styles/1app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem? item;
  final VoidCallback? onDelete;
  final Function(int)? onQuantityChanged;
  final Function(double)? onWeightChanged;
  final bool isLastItem;
  final bool isSkeleton;

  const CartItemWidget({
    Key? key,
    this.item,
    this.onDelete,
    this.onQuantityChanged,
    this.onWeightChanged,
    this.isLastItem = false,
    this.isSkeleton = false,
  }) : super(key: key);

  void _handleDelete() {
    HapticFeedback.mediumImpact();
    if (onDelete != null) onDelete!();
  }

  void _handleQuantityChanged(int value) {
    HapticFeedback.selectionClick();
    if (onQuantityChanged != null) onQuantityChanged!(value);
  }

  void _handleWeightChanged(double value) {
    HapticFeedback.selectionClick();
    if (onWeightChanged != null) onWeightChanged!(value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSkeleton) return _buildSkeleton(colorScheme);

    if (item == null) return const SizedBox();

    final priceText = item!.isWeightBased
        ? '${(item!.price * (item!.weight ?? 0) * 10).toInt()} ₽'
        : '${item!.price * item!.quantity} ₽';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, // Используем цвет поверхности темы
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(colorScheme),
            const SizedBox(width: 16),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item!.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item!.weight != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${item!.weight} кг',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.secondary,
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                      if (item!.weight == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Вес не указан',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme.secondary.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CartItemControl(
                              item: item!,
                              onQuantityChanged: _handleQuantityChanged,
                              onWeightChanged: _handleWeightChanged,
                              onAddToCart: () {},
                              isItemInCart: true,
                              maxQuantity: 999,
                              minWeight: 0.4,
                              maxWeight: 999,
                              isWeightBased: item!.isWeightBased,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            priceText,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme
                                      .onSurface, // цвет текста на фоне
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Кнопка удаления (правый верхний угол)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: _handleDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: colorScheme.error, // Красный из темы!
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(ColorScheme colorScheme) {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant,
      highlightColor: colorScheme.background,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 70,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 16,
                          width: 54,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Кнопка удалить — скелетон
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(ColorScheme colorScheme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 11,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: CachedNetworkImage(
        imageUrl: item?.thumbnailUrl ?? 'fallback_image_url',
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: colorScheme.surfaceVariant,
          highlightColor: colorScheme.background,
          child: Container(
            width: 70,
            height: 70,
            color: colorScheme.surface,
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error,
            size: 44, color: colorScheme.error.withOpacity(0.5)),
        fit: BoxFit.cover,
        width: 70,
        height: 70,
      ),
    );
  }
}
