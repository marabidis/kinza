import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandGreen = Color(0xFF11BB8D);

  // ── Gray scale ──────────────────────────────────────────────────────────────
  static const Color gray50 = Color(0xFFFAFAFC); // lightest – card background
  static const Color gray100 = Color(0xFFF4F6F8); // surfaces / sheets
  static const Color gray200 = Color(0xFFECECEC);
  static const Color gray300 = Color(0xFFE0E3E9); // strokes
  static const Color gray500 = Color(0xFF9EA6B3); // secondary text
  static const Color gray700 = Color(0xFF67768C); // primary text
  static const Color gray800 = Color(0xFF2D2F32); // headings / accents

  // ── Dark gray scale ─────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF181A1F); // основной фон
  static const Color darkSurface = Color(0xFF23262B); // карточки, панели
  static const Color darkCard = Color(0xFF23262B);
  static const Color darkOutline = Color(0xFF34384B);
  static const Color darkShadow = Color(0xFF101214);
  static const Color darkText = Color(0xFFE7E9ED);
  static const Color darkSecondaryText = Color(0xFF9EA6B3);

  // ── Accents & states ────────────────────────────────────────────────────────
  static const Color yellowAccent = Color(0xFFFFD600);
  static const Color errorColor = Color(0xFFFF5B5B);

  // ── Sizing tokens ───────────────────────────────────────────────────────────
  static const double cardRadius = 13;
  static const double cardPadding = 8;
  static const double imageRadius = 16;
  static const double priceTagRadius = 11;
  static const double priceTagFontSize = 13;
  static const double iconButtonSplashRadius = 18;

  // Horizontal menu
  static const double menuHeight = 38;
  static const double menuRadius = 11;
  static const double menuButtonRadius = 10;
  static const double menuButtonPadH = 13;
  static const double menuButtonPadV = 6;
  static const double menuEmojiSize = 16;
  static const double menuFontSize = 15;

  // Animations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 200);

  // ── Decorations helpers ─────────────────────────────────────────────────────
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration priceTagDecoration(BuildContext context) =>
      BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(priceTagRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      );

  // ── ThemeData: LIGHT ────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: brandGreen,
      onPrimary: Colors.white,
      secondary: Color.fromARGB(255, 45, 44, 41),
      onSecondary: gray800,
      error: errorColor,
      onError: Colors.white,
      background: gray50,
      onBackground: gray800,
      surface: gray100,
      onSurface: gray800,
      outline: gray300,
      outlineVariant: gray200,
      shadow: gray200,
      inverseSurface: gray800,
      onSurfaceVariant: gray500,
      scrim: Color(0xCC000000),
      surfaceTint: gray100,
    ),
    scaffoldBackgroundColor: gray50,
    appBarTheme: const AppBarTheme(
      backgroundColor: gray100,
      foregroundColor: gray800,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: gray800,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: gray700,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Color.fromARGB(255, 75, 80, 87),
      ),
      labelLarge: TextStyle(
        fontSize: priceTagFontSize,
        fontWeight: FontWeight.w700,
        color: gray800,
        letterSpacing: 0.1,
      ),
    ),
    dividerColor: gray300,
    cardColor: gray50,
    // Можешь добавить сюда кастомные темы кнопок и т.д. если нужно
  );

  // ── ThemeData: DARK ─────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: brandGreen,
      onPrimary: Colors.white,
      secondary: Color.fromARGB(255, 161, 161, 161),
      onSecondary: darkText,
      error: errorColor,
      onError: Colors.white,
      background: darkBg,
      onBackground: darkText,
      surface: darkSurface,
      onSurface: darkText,
      outline: darkOutline,
      outlineVariant: darkSecondaryText,
      shadow: darkShadow,
      inverseSurface: darkBg,
      onSurfaceVariant: darkSecondaryText,
      scrim: Color(0xCC000000),
      surfaceTint: darkSurface,
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: darkSecondaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: darkSecondaryText,
      ),
      labelLarge: TextStyle(
        fontSize: priceTagFontSize,
        fontWeight: FontWeight.w700,
        color: darkText,
        letterSpacing: 0.1,
      ),
    ),
    dividerColor: darkOutline,
    cardColor: darkCard,
    // Можешь добавить сюда кастомные темы кнопок и т.д. если нужно
  );
}
