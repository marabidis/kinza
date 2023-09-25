import 'package:flutter/material.dart';
import 'package:flutter_kinza/my_button.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CatalogItemWidget extends StatelessWidget {
  final bool isChecked;
  final String? blurHash;
  final String? imageUrl;
  final String title;
  final String description;
  final String category;
  final int price;
  final VoidCallback onAddToCart;
  final String? mark;
  final String? weight;

  CatalogItemWidget({
    this.imageUrl,
    required this.blurHash,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.onAddToCart,
    required this.weight,
    this.isChecked = false,
    this.mark,
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
                // Base image or blurhash
                (imageUrl == null || imageUrl!.isEmpty)
                    ? SizedBox(
                        width: 124,
                        height: 124,
                        child: BlurHash(
                          hash: blurHash!,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl!,
                        placeholder: (context, url) => BlurHash(
                            hash: 'UAHA,|~q18xbsq%2nOIA16RO8wIAxu-;%1Rj'),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: 124,
                        height: 124,
                      ),
                // Mark overlay
                if (mark != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildMarkWidget(mark!),
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff101928),
                    // height: 19 / 16,
                  ),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff67768c),
                ),
              ),
              Row(
                children: [
                  MyButton(
                    isChecked: isChecked,
                    buttonText: '$price₽',
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
        backgroundColor = Color.fromRGBO(255, 71, 71, 1);
        // children.add(Icon(Icons.fireplace,
        // color: Colors
        //    .white)); // Используйте белый цвет для лучшего контраста с фоном
        children.add(Text('острая', style: TextStyle(color: Colors.white)));
        break;

      case 'дети обожают':
        backgroundColor = Color.fromRGBO(255, 71, 193, 1);
        // children.add(Icon(Icons.child_care, color: Colors.white));
        children
            .add(Text('дети обожают', style: TextStyle(color: Colors.white)));
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
