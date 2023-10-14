import 'package:flutter/material.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/models/product.dart';

class CatalogItemWidget extends StatelessWidget {
  final bool isChecked;
  final Product product;
  final VoidCallback onAddToCart;

  CatalogItemWidget({
    required this.product,
    required this.onAddToCart,
    this.isChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 13, top: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                (product.imageUrl?.thumbnailUrl == null ||
                        product.imageUrl!.thumbnailUrl.isEmpty)
                    ? SizedBox(
                        width: 124,
                        height: 124,
                        child: BlurHash(
                          hash: product.blurHash,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: product.imageUrl!.thumbnailUrl,
                        placeholder: (context, url) => BlurHash(
                          hash: product.blurHash,
                        ),
                        errorWidget: (context, url, error) {
                          print('Failed to load image: $error');
                          return Icon(Icons.error);
                        },
                        fit: BoxFit.cover,
                        width: 124,
                        height: 124,
                      ),
                if (product.mark != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildMarkWidget(product.mark!),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 18, bottom: 8),
                child:
                    Text(product.title, style: AppStyles.catalogItemTitleStyle),
              ),
              Text(product.description,
                  style: AppStyles.catalogItemDescriptionStyle),
              Row(
                children: [
                  MyButton(
                    isChecked: isChecked,
                    buttonText: '${product.price}₽',
                    onPressed: onAddToCart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkWidget(String mark) {
    Color backgroundColor;
    List<Widget> children = []; // Для иконки и текста (если потребуется)

    switch (mark) {
      case 'острая':
        backgroundColor = AppColors.red;
        children.add(Text('острая', style: TextStyle(color: AppColors.white)));
        break;

      case 'дети обожают':
        backgroundColor = AppColors.pink;
        children.add(
            Text('дети обожают', style: TextStyle(color: AppColors.white)));
        break;

      default:
        return Container();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Чтобы контейнер обтягивал содержимое
        mainAxisAlignment: MainAxisAlignment.center, // Добавлено
        crossAxisAlignment: CrossAxisAlignment.center, // Добавлено
        children: children,
      ),
    );
  }
}
