import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class MyButton extends StatelessWidget {
  final bool isChecked;
  final String buttonText;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? checkedColor;
  final Color? textColor;
  final FontWeight fontWeight;
  final double fontSize;

  MyButton({
    required this.buttonText,
    required this.onPressed,
    required this.isChecked,
    this.height = 48, // default 48
    this.borderRadius = 16, // default 16
    this.backgroundColor,
    this.checkedColor,
    this.textColor,
    this.fontWeight = FontWeight.w700,
    this.fontSize = 18, // default 18
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = isChecked;
    final Color bgColor = isSelected
        ? (checkedColor ?? const Color(0xFFF3F6F9))
        : (backgroundColor ?? const Color(0xFFFFD600));
    final Color textColor = isSelected
        ? (this.textColor ?? const Color(0xFF9CA3AF))
        : (this.textColor ?? Colors.black);
    final double height = this.height;
    final double borderRadius = this.borderRadius;
    final double fontSize = this.fontSize;
    final FontWeight fontWeight = this.fontWeight;
    final String displayText = isSelected ? 'В корзине' : buttonText;

    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: () {
              HapticFeedback.mediumImpact();
              onPressed();
            },
            child: Center(
              child: Text(
                displayText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  fontFamily: 'sans-serif',
                  letterSpacing: 0.01,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
