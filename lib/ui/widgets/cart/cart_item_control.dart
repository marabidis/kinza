import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/cart_item.dart';

class CartItemControl extends StatefulWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onAddToCart;
  final bool isItemInCart;
  final int maxQuantity;
  final double minWeight;
  final double maxWeight;
  final bool isWeightBased;

  const CartItemControl({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onWeightChanged,
    required this.onAddToCart,
    required this.isItemInCart,
    this.maxQuantity = 999,
    this.minWeight = 0.4,
    this.maxWeight = 999,
    this.isWeightBased = false,
  }) : super(key: key);

  @override
  _CartItemControlState createState() => _CartItemControlState();
}

class _CartItemControlState extends State<CartItemControl> {
  int _quantity = 0;
  double _weight = 0.0;

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
        _buildButton("-", () => _updateValue(_quantity - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(103, 118, 140, 1),
            ),
          ),
        ),
        _buildButton("+", () => _updateValue(_quantity + 1)),
        // Цена УДАЛЕНА отсюда!
      ],
    );
  }

  Widget _buildWeightControl() {
    return Row(
      children: [
        _buildButton("-", () {
          _updateValue(
            double.parse(
              (_weight - (widget.isWeightBased ? 0.1 : 1)).toStringAsFixed(1),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            _weight.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(103, 118, 140, 1),
            ),
          ),
        ),
        _buildButton("+", () {
          _updateValue(
            double.parse(
              (_weight + (widget.isWeightBased ? 0.1 : 1)).toStringAsFixed(1),
            ),
          );
        }),
        // Цена УДАЛЕНА отсюда!
      ],
    );
  }

  void _updateValue(double newValue) {
    if (newValue >
        (widget.isWeightBased ? widget.maxWeight : widget.maxQuantity)) {
      return;
    }
    if (newValue == (widget.isWeightBased ? _weight : _quantity)) {
      return;
    }
    if (widget.isWeightBased &&
        newValue < (widget.item.minimumWeight ?? widget.minWeight)) {
      return;
    }
    if (!widget.isWeightBased && newValue < 1) {
      return;
    }

    setState(() {
      if (widget.isWeightBased) {
        _weight = newValue;
        widget.onWeightChanged(newValue);
      } else {
        _quantity = newValue.toInt();
        widget.onQuantityChanged(newValue.toInt());
      }
      widget.onAddToCart();
      HapticFeedback.mediumImpact();
    });
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 30,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color.fromRGBO(103, 118, 140, 0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
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
