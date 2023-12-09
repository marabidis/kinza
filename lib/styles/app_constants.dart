import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color green = Color.fromRGBO(149, 202, 32, 1);
  static const Color black = Color.fromRGBO(16, 25, 40, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color grey = Color.fromRGBO(103, 118, 140, 1);
  static const Color red = Color.fromRGBO(255, 71, 71, 1);
  static const Color pink = Color.fromRGBO(255, 71, 193, 1);
  static const Color orange = Color.fromRGBO(255, 105, 0, 1);
  static const Color whitegrey = Color.fromRGBO(195, 195, 195, 1);
}

class AppConstants {
  static const double indent = 10.0;

  static const double padding = 16.0;
  static const double paddingSmall = 12.0;
  static const double paddingLarge = 20.0;

  static const double margin = 16.0;
  static const double marginSmall = 12.0;
  static const double marginLarge = 20.0;

  static const double baseRadius = 10;
}

class AppStyles {
  static const TextStyle catalogItemTitleStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 19 / 16, // line-height to font-size ratio
    letterSpacing: 0,
    color: AppColors.black,
  );

  static const TextStyle catalogItemDescriptionStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 14 / 12, // line-height to font-size ratio
    letterSpacing: 0,
    color: AppColors.grey,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.2,
  );

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: AppConstants.padding,
      vertical: AppConstants.paddingSmall,
    ),
    backgroundColor: AppColors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    elevation: 0,
  );
}
