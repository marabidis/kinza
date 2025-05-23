import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class FloatingCartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const FloatingCartButton({
    Key? key,
    required this.itemCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.16),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Center(
              child: SvgPicture.asset(
                'assets/shopping_cart.svg',
                width: 28,
                height: 28,
                color: itemCount > 0
                    ? Colors.white
                    : Colors.white.withOpacity(0.60),
              ),
            ),
            if (itemCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Container(
                    key: ValueKey<int>(itemCount),
                    constraints: BoxConstraints(minWidth: 26, minHeight: 22),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.red.withOpacity(0.18),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
