import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      backgroundColor: Color.fromRGBO(149, 202, 32, 1),
      child: Stack(
        children: <Widget>[
          SvgPicture.asset(
              'assets/shopping_cart.svg'), // путь к вашему SVG файлу

          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 57, 57, 1),
              ),
              constraints: BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                '$itemCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
