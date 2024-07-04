import 'package:flutter/material.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;
  final Function(int) onQuantityChanged;
  final Function(double) onWeightChanged;
  final bool isLastItem;

  CartItemWidget({
    required this.item,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: _buildItemImage(),
          title: Text(item.title, style: AppStyles.catalogItemTitleStyle),
          subtitle: Text(
            item.weight != null ? '${item.weight} кг' : 'Вес не указан',
            style: AppStyles.catalogItemDescriptionStyle,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: AppColors.whitegrey),
            onPressed: onDelete,
          ),
        ),
        CartItemControl(
          item: item,
          onQuantityChanged: onQuantityChanged,
          onWeightChanged: onWeightChanged,
          onAddToCart: () {
            // Логика для добавления товара в корзину
          },
          isItemInCart:
              true, // или false, в зависимости от того, находится ли товар в корзине
          maxQuantity: 999,
          minWeight: 0.4,
          maxWeight: 999,
          isWeightBased: item.isWeightBased,
        ),
        if (!isLastItem) ...[
          SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
        ]
      ],
    );
  }

  Widget _buildItemImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: CachedNetworkImage(
        imageUrl: item.thumbnailUrl ?? 'fallback_image_url',
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 70,
            height: 70,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
        fit: BoxFit.cover,
        width: 70,
        height: 70,
      ),
    );
  }
}
