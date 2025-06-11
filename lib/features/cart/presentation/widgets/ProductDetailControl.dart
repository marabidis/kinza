import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinza/core/models/cart_item.dart';

class ProductDetailControl extends StatefulWidget {
  final CartItem item;
  final void Function(int, double) onAddToCart;
  final int maxQuantity;
  final double minWeight;
  final double maxWeight;
  final bool isWeightBased;

  ProductDetailControl({
    required this.item,
    required this.onAddToCart,
    this.maxQuantity = 999,
    this.minWeight = 0.4,
    this.maxWeight = 999,
    this.isWeightBased = false,
  });

  @override
  _ProductDetailControlState createState() => _ProductDetailControlState();
}

class _ProductDetailControlState extends State<ProductDetailControl> {
  int _quantity = 1;
  double _weight = 0.4;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
    _weight = widget.item.weight ?? widget.minWeight;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isWeightBased
        ? _buildWeightControl()
        : _buildQuantityControl();
  }

  Widget _buildQuantityControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton("-", () => _updateQuantity(_quantity - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w700, // Жирный
              color: Color(0xFF67768C),
              letterSpacing: 0.2,
            ),
          ),
        ),
        _buildButton("+", () => _updateQuantity(_quantity + 1)),
      ],
    );
  }

  Widget _buildWeightControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton("-", () {
          _updateWeight(
              (_weight - 0.1).clamp(widget.minWeight, widget.maxWeight));
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            _weight.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w700, // Жирный
              color: Color(0xFF67768C),
              letterSpacing: 0.2,
            ),
          ),
        ),
        _buildButton("+", () {
          _updateWeight(
              (_weight + 0.1).clamp(widget.minWeight, widget.maxWeight));
        }),
      ],
    );
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity < 1 || newQuantity > widget.maxQuantity) return;
    setState(() {
      _quantity = newQuantity;
    });
    HapticFeedback.selectionClick();
  }

  void _updateWeight(double newWeight) {
    if (newWeight < widget.minWeight || newWeight > widget.maxWeight) return;
    setState(() {
      _weight = double.parse(newWeight.toStringAsFixed(1));
    });
    HapticFeedback.selectionClick();
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 34,
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFECECEC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF67768C),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
