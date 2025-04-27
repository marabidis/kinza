import 'package:flutter/material.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class EmptyCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/cat.png', height: 150),
          SizedBox(height: 20),
          Text("Пока, тут пусто!", style: AppStyles.subtitleTextStyle),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0), // увеличиваем отступы
            child: Text(
                "Корзина пуста, но это не повод грустить! Загляните в меню и добавьте что-нибудь вкусненькое!",
                style: AppStyles.bodyTextStyle,
                textAlign: TextAlign.center),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("Перейти в меню", style: AppStyles.buttonTextStyle),
            style: AppStyles.elevatedButtonStyle,
          ),
        ],
      ),
    );
  }
}
