import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class MyButton extends StatefulWidget {
  final bool isChecked;
  final String buttonText;
  final Function() onPressed;

  MyButton({
    required this.buttonText,
    required this.onPressed,
    required this.isChecked,
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isClicked = false;

  @override
  void initState() {
    _isClicked = widget.isChecked;
    super.initState();
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
                ? Color(0x94CA2033)
                : AppColors.green; // используйте AppColors.green
          },
        ),
        elevation: MaterialStateProperty.all(0.0),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: AppConstants.paddingSmall)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants
              .baseRadius), // используйте AppConstants для радиуса скругления
        )),
      ),
      child: Text(
        _isClicked ? 'В корзине' : widget.buttonText,
        style: AppStyles.buttonTextStyle, // Установите стиль текста здесь
      ),
    );
  }
}
