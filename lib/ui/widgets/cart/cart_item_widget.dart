import 'package:flutter/material.dart';
import 'package:flutter_kinza/models/cart_item.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/ui/widgets/cart/cart_item_control.dart';

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
            icon: Icon(Icons.delete,
                color: AppColors.whitegrey), // Используем whitegrey
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
          SizedBox(height: 16), // Отступ после Divider
          Divider(
            height: 1,
            thickness: 0.5, // Толщина линии
            color: Colors.grey[300], // Цвет линии
          ),
          SizedBox(height: 16), // Отступ после Divider
        ]
      ],
    );
  }

  Widget _buildItemImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(item.thumbnailUrl ?? 'fallback_image_url'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
