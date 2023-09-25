import 'package:flutter/material.dart';

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
    if (widget.isChecked != oldWidget.isChecked) {
      _isClicked = widget.isChecked;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isClicked = !_isClicked;
        });
        widget.onPressed();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          _isClicked ? Color(0x94CA2033) : Color(0xFF95CA20),
        ),
        elevation: MaterialStateProperty.all(0.0),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 18, vertical: 8)),
        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 14)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        )),
      ),
      child: Text(
        _isClicked ? 'В корзине' : widget.buttonText,
      ),
    );
  }
}
