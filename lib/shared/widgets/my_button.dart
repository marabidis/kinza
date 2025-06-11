import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyButton extends StatelessWidget {
  final bool isChecked;
  final String buttonText;
  final VoidCallback onPressed;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? checkedColor;
  final Color? textColor;
  final FontWeight fontWeight;
  final double fontSize;

  const MyButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    required this.isChecked,
    this.height,
    this.borderRadius = 12,
    this.backgroundColor,
    this.checkedColor,
    this.textColor,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bool isSelected = isChecked;
    final Color bgColor = isSelected
        ? (checkedColor ?? colorScheme.surfaceVariant)
        : (backgroundColor ?? colorScheme.primary);
    final Color fgColor = isSelected
        ? (textColor ?? colorScheme.onSurfaceVariant)
        : (textColor ?? colorScheme.onPrimary);

    final double btnRadius = borderRadius;
    final double btnFontSize = fontSize;
    final FontWeight btnFontWeight = fontWeight;
    final String displayText = isSelected ? 'В корзине' : buttonText;

    final child = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Text(
          displayText,
          style: textTheme.labelLarge?.copyWith(
            color: fgColor,
            fontWeight: btnFontWeight,
            fontSize: btnFontSize,
            letterSpacing: 0.01,
          ),
        ),
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(btnRadius),
        border: Border.all(
          color: isSelected
              ? colorScheme.outlineVariant
              : Colors
                  .transparent, // ВСЕГДА border, просто прозрачный если не выбран
          width: 1.0,
        ),
        boxShadow: !isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(btnRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(btnRadius),
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: child,
        ),
      ),
    );

    return height != null
        ? SizedBox(height: height, child: decorated)
        : decorated;
  }
}
