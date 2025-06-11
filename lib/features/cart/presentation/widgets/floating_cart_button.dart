// lib/ui/widgets/cart/floating_cart_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kinza/core/theme/app_theme.dart';

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
    final cs = Theme.of(context).colorScheme;

    final Color fabColor = cs.primary;
    final Color iconColor =
        itemCount > 0 ? cs.onPrimary : cs.onPrimary.withOpacity(.60);

    final Color badgeColor = cs.error;
    final shadowColor = fabColor.withOpacity(.16);

    return Semantics(
      button: true,
      label: 'Корзина, товаров: $itemCount',
      child: SizedBox(
        width: 56,
        height: 56,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          // ---- исправлено: ничего не обрезаем -------------------------
          clipBehavior: Clip.none, //  <-- FIX (было Clip.antiAlias)
          //----------------------------------------------------------------
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: fabColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none, //  <-- FIX (чтобы потом не обрезало)
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/shopping_cart.svg',
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: AnimatedSwitcher(
                        duration: AppTheme.animNormal,
                        switchInCurve: Curves.elasticOut,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _Badge(
                          key: ValueKey<int>(itemCount),
                          count: itemCount,
                          badgeColor: badgeColor,
                          borderColor: cs.surface,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color badgeColor;
  final Color borderColor;

  const _Badge({
    Key? key,
    required this.count,
    required this.badgeColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
