import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 24), // Отступ слева 16px
      child: Text(
        "Пиццы",
        style: TextStyle(
          fontFamily: "Roboto",
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xff101928),
          height: 29 / 24,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
