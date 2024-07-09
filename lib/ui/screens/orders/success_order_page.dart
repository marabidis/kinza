import 'package:flutter/material.dart';
import 'package:kinza/styles/app_constants.dart';
import 'package:flutter/services.dart';

class SuccessOrderPage extends StatelessWidget {
  final int orderNumber; // Объявите orderNumber как final

  SuccessOrderPage({required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убрали AppBar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Заменили иконку на изображение из ресурсов
            Image.asset('assets/pizza-deliver.png', width: 150, height: 150),
            SizedBox(height: 20),
            Text('Заказ №$orderNumber оформлен!👌🏽',
                style: AppStyles.titleTextStyle),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants
                    .padding, // используем значение отступа из AppConstants
              ),
              child: Text(
                'Скоро наш администратор свяжется с вами для уточнения деталей.',
                style: AppStyles.bodyTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20), // Добавить этот виджет для отступа
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.padding,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();

                    Navigator.popUntil(
                        context,
                        (route) => route
                            .isFirst); // Этот метод приведет вас к первой странице в стеке маршрутов (обычно главной).
                  },
                  child: Text(
                    "Перейти в меню",
                    style: AppStyles.buttonTextStyle,
                  ),
                  style: AppStyles.elevatedButtonStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
