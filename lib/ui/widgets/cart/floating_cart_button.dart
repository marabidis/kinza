import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class FloatingCartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  FloatingCartButton({
    required this.itemCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.green,
      child: Stack(
        children: <Widget>[
          SvgPicture.asset(
              'assets/shopping_cart.svg'), // путь к вашему SVG файлу
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8), // Уменьшенный padding
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red,
              ),
              constraints: BoxConstraints(
                minWidth: 12, // Минимальный размер, соответствующий тексту
                minHeight: 12,
              ),
              child: Text(
                '$itemCount',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12, // Уменьшенный размер шрифта
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
