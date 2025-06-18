// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  /*──────────────── COLOR CONSTANTS ────────────────*/
  static const Color brandGreen = Color(0xFF11BB8D);

  // Gray scale (light)
  static const Color gray50 = Color(0xFFFAFAFC);
  static const Color gray100 = Color(0xFFF4F6F8);
  static const Color gray200 = Color(0xFFECECEC);
  static const Color gray300 = Color(0xFFE0E3E9);
  static const Color gray500 = Color(0xFF9EA6B3);
  static const Color gray700 = Color(0xFF67768C);
  static const Color gray800 = Color(0xFF2D2F32);

  // Dark scale
  static const Color darkBg = Color(0xFF181A1F);
  static const Color darkSurface = Color(0xFF23262B);
  static const Color darkCard = Color(0xFF23262B);
  static const Color darkOutline = Color(0xFF34384B);
  static const Color darkShadow = Color(0xFF101214);
  static const Color darkText = Color(0xFFE7E9ED);
  static const Color darkSecondaryTxt = Color(0xFF9EA6B3);

  // Accents & states
  static const Color yellowAccent = Color(0xFFFFD600);
  static const Color errorColor = Color(0xFFFF5B5B);

  /*──────────────── SIZE TOKENS ───────────────────*/
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

  /*──────────────── DECORATIONS ───────────────────*/
  static BoxDecoration cardDecoration(BuildContext ctx) => BoxDecoration(
        color: Theme.of(ctx).cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(ctx).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration priceTagDecoration(BuildContext ctx) => BoxDecoration(
        color: Theme.of(ctx).colorScheme.surface,
        borderRadius: BorderRadius.circular(priceTagRadius),
        border: Border.all(
          color: Theme.of(ctx).colorScheme.outline,
          width: 1.2,
        ),
      );

  /*──────────────── THEME (LIGHT) ─────────────────*/
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: brandGreen,
      onPrimary: Colors.white,
      secondary: Color(0xFF2D2C29),
      onSecondary: gray800,
      error: errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1D1E20),
      surfaceContainerHighest: Color(0xFFF9F9FB), // чуть контрастнее стекло
      onSurfaceVariant: Color(0xFF4A505E), // темнее подписи
      outline: gray300,
      outlineVariant: gray200,
      shadow: Color(0x331D1E20),
      inverseSurface: Color(0xFF1D1E20),
      scrim: Color(0xCC000000),
      surfaceTint: Colors.white,
    ),
    scaffoldBackgroundColor: gray50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1D1E20),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1E20),
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Color(0xFF4A505E), // обновлено
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Color(0xFF6A7282),
      ),
      labelLarge: TextStyle(
        fontSize: priceTagFontSize,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1E20),
        letterSpacing: 0.1,
      ),
    ),
    dividerColor: gray300,
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: Color(0x331D1E20),
      margin: EdgeInsets.zero,
    ),
  );

  /*──────────────── THEME (DARK) ──────────────────*/
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: brandGreen,
      onPrimary: Colors.white,
      secondary: Color(0xFFA1A1A1),
      onSecondary: darkText,
      error: errorColor,
      onError: Colors.white,
      surface: darkSurface,
      onSurface: darkText,
      surfaceContainerHighest: darkSurface,
      onSurfaceVariant: darkSecondaryTxt,
      outline: darkOutline,
      outlineVariant: darkSecondaryTxt,
      shadow: darkShadow,
      inverseSurface: darkBg,
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
        color: darkSecondaryTxt,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: darkSecondaryTxt,
      ),
      labelLarge: TextStyle(
        fontSize: priceTagFontSize,
        fontWeight: FontWeight.w700,
        color: darkText,
        letterSpacing: 0.1,
      ),
    ),
    dividerColor: darkOutline,
    cardTheme: const CardTheme(
      color: darkCard,
      elevation: 2,
      shadowColor: Color(0x66101214),
      margin: EdgeInsets.zero,
    ),
  );
}
