import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class MyButton extends StatefulWidget {
  final bool isChecked;
  final String buttonText;
  final VoidCallback onPressed;

  MyButton({
    required this.buttonText,
    required this.onPressed,
    required this.isChecked,
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  late bool _isClicked;

  @override
  void initState() {
    super.initState();
    _isClicked = widget.isChecked;
  }

  @override
  void didUpdateWidget(covariant MyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      setState(() {
        _isClicked = widget.isChecked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _isClicked = !_isClicked;
        });
        widget.onPressed();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return _isClicked
                ? Color(0xFFCA2033) // Изменено значение цвета
                : AppColors.green; // Используется константа AppColors
          },
        ),
        elevation: MaterialStateProperty.all(0.0),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: AppConstants.paddingSmall)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        )),
      ),
      child: Text(
        _isClicked ? 'В корзине' : widget.buttonText,
        style: AppStyles.buttonTextStyle,
      ),
    );
  }
}
