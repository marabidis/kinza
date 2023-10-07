import 'package:flutter/material.dart';
import '../../../models/cart_item.dart';

class CartItemControl extends StatefulWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback
      onAddToCart; // новый колбек для добавления товара в корзину
  final bool
      isItemInCart; // новый параметр для проверки, находится ли товар уже в корзине
  final int maxQuantity;
  final double minWeight;
  final double maxWeight;
  final bool isWeightBased;

  CartItemControl({
    required this.item,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.onAddToCart, // инициализация нового колбека
    required this.isItemInCart, // инициализация нового параметра
    this.maxQuantity = 999,
    this.minWeight = 0.4,
    this.maxWeight = 999,
    this.isWeightBased = false,
  });

  @override
  _CartItemControlState createState() => _CartItemControlState();
}

class _CartItemControlState extends State<CartItemControl> {
  int _quantity = 0;
  double _weight = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
    _weight = widget.item.weight ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isWeightBased
        ? _buildWeightControl()
        : _buildQuantityControl();
  }

  Widget _buildQuantityControl() {
    return Row(
      children: [
        _buildButton("-", () {
          _updateValue(_quantity - 1);
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
          _updateValue(_quantity + 1);
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

  Widget _buildWeightControl() {
    return Row(
      children: [
        _buildButton("-", () {
          _updateValue(double.parse(
              (_weight - (widget.isWeightBased ? 0.1 : 1)).toStringAsFixed(1)));
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            _weight.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(103, 118, 140, 1),
            ),
          ),
        ),
        _buildButton("+", () {
          _updateValue(double.parse(
              (_weight + (widget.isWeightBased ? 0.1 : 1)).toStringAsFixed(1)));
        }),
        SizedBox(width: 20),
        Text(
          '${(widget.item.price * _weight * 10).toStringAsFixed(2).contains('.00') ? (widget.item.price * _weight * 10).toInt().toString() : (widget.item.price * _weight * 10).toStringAsFixed(2)} ₽', // умножаем на 10, если цена указана за 0.1 кг
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _updateValue(double newValue) {
    if (newValue >
        (widget.isWeightBased ? widget.maxWeight : widget.maxQuantity)) {
      return; // Не позволяем выходить за границы значения
    }

    if (newValue == (widget.isWeightBased ? _weight : _quantity)) {
      return; // Если значение не изменилось, ничего не делаем
    }

    // Проверяем, что вес не уменьшается ниже минимального веса из базы данных
    if (widget.isWeightBased && newValue < (widget.item.minimumWeight ?? 0.4)) {
      return;
    }

    if (!widget.isItemInCart) {
      widget
          .onAddToCart(); // автоматически добавляем товар в корзину, если он еще не в корзине
    }

    setState(() {
      if (widget.isWeightBased) {
        _weight = newValue;
        widget.onWeightChanged(newValue);
      } else {
        _quantity = newValue.toInt();
        widget.onQuantityChanged(newValue.toInt());
      }
    });
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
