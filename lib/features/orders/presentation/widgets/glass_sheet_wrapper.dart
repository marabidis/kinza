// lib/features/orders/presentation/widgets/glass_sheet_wrapper.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSheetWrapper extends StatelessWidget {
  const GlassSheetWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          // Для светлой темы — почти чисто белый "стеклянный" цвет,
          // для тёмной — мягкий чёрный для полупрозрачности
          color: dark
              ? Colors.black.withOpacity(.22)
              : cs.surfaceContainerHighest.withOpacity(.90),
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}
