import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
import '../../../models/cart_item.dart';

class CartItemControl extends StatefulWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final int maxQuantity;

  CartItemControl({
    required this.item,
    required this.onQuantityChanged,
    this.maxQuantity = 999,
  });

  @override
  _CartItemControlState createState() => _CartItemControlState();
}

class _CartItemControlState extends State<CartItemControl> {
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton("-", () {
          _updateQuantity(_quantity - 1);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            '$_quantity',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(103, 118, 140, 1),
            ),
          ),
        ),
        _buildButton("+", () {
          _updateQuantity(_quantity + 1);
        }),
        SizedBox(width: 20),
        Text(
          '${widget.item.price * _quantity} ₽',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity > widget.maxQuantity) {
      return; // Не позволяем выходить за границу максимального количества
    }

    if (newQuantity == _quantity) {
      return; // Если количество не изменилось, ничего не делаем
    }

    if (newQuantity <= 0) {
      setState(() {
        _quantity = 0;
      });
      widget.onQuantityChanged(newQuantity);
    } else {
      setState(() {
        _quantity = newQuantity;
      });

      widget.onQuantityChanged(newQuantity);
    }
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 23,
      height: 23,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6.5),
          primary: Color.fromRGBO(103, 118, 140, 0.1),
          elevation: 0, // Убираем тень под кнопкой
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(103, 118, 140, 1),
            ),
          ),
        ),
      ),
    );
  }
}
