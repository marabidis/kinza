import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class SuccessOrderPage extends StatelessWidget {
  final int orderNumber;

  const SuccessOrderPage({required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // тот же белый фон
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Белый круг с тенью — размеры как в EmptyCartScreen
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
                  padding: EdgeInsets.all(40), // Синхронизирован с корзиной
                  child: Image.asset(
                    'assets/success_order_kinza_white_bg.png',
                    width: 170, // Точно так же как в корзине
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 36),
                Text(
                  'Заказ №$orderNumber оформлен! 👌🏽',
                  style: AppStyles.subtitleTextStyle.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Скоро наш администратор свяжется с вами для уточнения деталей.',
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: const Color(0xFF67768C),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 44, // Точно как в EmptyCartScreen
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: AppStyles.elevatedButtonStyle.copyWith(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFFFFD600)),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      ),
                    ),
                    child: Text(
                      "В меню",
                      style: AppStyles.buttonTextStyle.copyWith(
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
