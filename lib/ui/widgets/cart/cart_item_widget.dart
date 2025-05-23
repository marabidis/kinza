import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

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
    if (isSkeleton) return _buildSkeleton(context);

    if (item == null) return const SizedBox();

    final priceText = item!.isWeightBased
        ? '${(item!.price * (item!.weight ?? 0) * 10).toInt()} ₽'
        : '${item!.price * item!.quantity} ₽';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(),
            SizedBox(width: 16),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item!.title,
                        style: AppStyles.catalogItemTitleStyle.copyWith(
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
                                AppStyles.catalogItemDescriptionStyle.copyWith(
                              color: Color(0xFF67768C),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (item!.weight == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Вес не указан',
                            style:
                                AppStyles.catalogItemDescriptionStyle.copyWith(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
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
                          SizedBox(width: 14),
                          Text(
                            priceText,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Компактная кнопка удаления
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: _handleDelete,
                        child: Container(
                          width: 28, // Сделали меньше
                          height: 28,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.red,
                            size: 22, // Сделали меньше
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

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Вес/описание
                      Container(
                        height: 12,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Контрол (условно длинный прямоугольник)
                      Container(
                        height: 36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Цена
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 16,
                          width: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Компактная кнопка удалить (скелетон)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
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

  Widget _buildItemImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 11,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: item?.thumbnailUrl ?? 'fallback_image_url',
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 70,
              height: 70,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.error, size: 44, color: Colors.grey[400]),
          fit: BoxFit.cover,
          width: 70,
          height: 70,
        ),
      ),
    );
  }
}
