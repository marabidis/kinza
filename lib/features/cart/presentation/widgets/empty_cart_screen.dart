import 'package:flutter/material.dart';

class EmptyCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // <-- используем фон темы!
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
                    color: colorScheme.surface, // <-- фон круга по теме
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.07),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Image.asset(
                    'assets/sad_kitten_white_bg.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  "Пока, тут пусто!",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Добавьте что-нибудь вкусное из меню!",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                // КОМПАКТНАЯ КНОПКА
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      minimumSize: const Size(double.infinity, 44),
                      elevation: 0,
                    ),
                    child: Text(
                      "В каталог",
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                            colorScheme.onPrimary, // цвет текста кнопки по теме
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
