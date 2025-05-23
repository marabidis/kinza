import 'package:flutter/material.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class EmptyCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // КРУГ КРУПНЕЕ, КАРТИНКА БОЛЬШЕ
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 28,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(40),
                  child: Image.asset(
                    'assets/sad_kitten_white_bg.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 36),
                Text(
                  "Пока, тут пусто!",
                  style: AppStyles.subtitleTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Добавьте что-нибудь вкусное из меню!",
                    style: AppStyles.bodyTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40),
                // КОМПАКТНАЯ КНОПКА
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(
                      "В каталог",
                      style: AppStyles.buttonTextStyle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: AppStyles.elevatedButtonStyle.copyWith(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(vertical: 0),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 44),
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
