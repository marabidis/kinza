// lib/ui/widgets/cart/delivery_info_bottom_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class DeliveryInfoBottomSheet extends StatelessWidget {
  const DeliveryInfoBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: dark
                ? Colors.black.withOpacity(.35)
                : Colors.white.withOpacity(.30),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(dark ? .12 : .18),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Условия доставки',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _condition('От 800 ₽ — доставка бесплатно', cs),
              Divider(color: cs.outlineVariant, height: 22),
              _condition('До 800 ₽ — доставка 100 ₽', cs),
              Divider(color: cs.outlineVariant, height: 22),
              _condition('Доставляем с 9:00 до 21:00', cs),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Понятно',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _condition(String text, ColorScheme cs) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          text,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      );
}
