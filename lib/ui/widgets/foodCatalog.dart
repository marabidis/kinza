import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/models/product.dart';
import 'package:flutter_kinza/ui/widgets/my_button.dart';

class CatalogItemWidget extends StatelessWidget {
  final bool isChecked;
  final Product product;
  final VoidCallback onAddToCart;

  CatalogItemWidget({
    required this.product,
    required this.onAddToCart,
    this.isChecked = false,
  });

  Widget _buildImage() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 13, top: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl:
                  product.imageUrl?.thumbnailUrl ?? 'placeholder_image_url',
              placeholder: (context, url) => BlurHash(hash: product.blurHash),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
              width: AppConstants.imageSize,
              height: AppConstants.imageSize,
            ),
            if (product.mark != null)
              Positioned(
                top: 10,
                right: 10,
                child: _buildMarkWidget(product.mark!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkWidget(String mark) {
    Color backgroundColor;
    List<Widget> children = [];

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
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildImage(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 18, bottom: 8),
                child:
                    Text(product.title, style: AppStyles.catalogItemTitleStyle),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: AppConstants.marginSmall),
                child: Text(product.description,
                    style: AppStyles.catalogItemDescriptionStyle),
              ),
              MyButton(
                isChecked: isChecked,
                buttonText: '${product.price}₽',
                onPressed: onAddToCart,
              ),
              // Убран вызов _buildMarkWidget здесь, чтобы избежать дублирования
            ],
          ),
        ),
      ],
    );
  }
}

class AppConstants {
  static const double imageSize = 124.0;
  static const double baseRadius = 15.0;
  static const double marginSmall = 8.0;
  // Другие константы...
}
