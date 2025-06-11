// lib/ui/screens/orders/product/glass_sheet_wrapper.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSheetWrapper extends StatelessWidget {
  const GlassSheetWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      // Скругляем только верхние углы
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          // При тёмной теме чуть-чуть более тёмный фон; иначе — светлый полупрозрачный
          color: dark
              ? Colors.black.withOpacity(.35)
              : Colors.white.withOpacity(.30),
          // SafeArea(top: false) чтобы внутрь не залезало в notch на телефонах
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}
