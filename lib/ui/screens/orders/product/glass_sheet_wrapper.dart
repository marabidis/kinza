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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: dark
              ? Colors.black.withOpacity(.35)
              : Colors.white.withOpacity(.30),
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}
