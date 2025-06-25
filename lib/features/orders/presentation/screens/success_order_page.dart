// lib/ui/screens/orders/success_order_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinza/core/theme/app_theme.dart'; // Импорт AppTheme для фирменных цветов

class SuccessOrderPage extends StatelessWidget {
  final int orderNumber;

  const SuccessOrderPage({required this.orderNumber, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Круглая картинка на фоне карточки темы
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withOpacity(0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Image.asset(
                    dark
                        ? 'assets/success_order.webp'
                        : 'assets/success_order.webp',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Заказ №$orderNumber оформлен! 👌🏽',
                  style: txt.titleLarge?.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Скоро наш администратор свяжется с вами для уточнения деталей.',
                    style: txt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yellowAccent, // ЯВНО ЖЁЛТЫЙ
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "В меню",
                      style: txt.labelLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
