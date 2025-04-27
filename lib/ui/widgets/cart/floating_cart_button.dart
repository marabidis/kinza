import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        clipBehavior: Clip.none,
        children: <Widget>[
          Center(
            child: SvgPicture.asset(
              'assets/shopping_cart.svg',
              fit: BoxFit.contain,
            ),
          ),
          if (itemCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey<int>(itemCount),
                  padding: EdgeInsets.all(
                      6), // Увеличенный padding для улучшенной видимости
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red,
                  ),
                  constraints: BoxConstraints(
                    minWidth:
                        20, // Увеличенный минимальный размер для лучшей видимости
                    minHeight: 20,
                  ),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize:
                          12, // Увеличенный размер шрифта для улучшенной читабельности
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
