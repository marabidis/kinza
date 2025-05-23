import 'package:flutter/material.dart';

class AnimatedPrice extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final bool showPrefix;

  const AnimatedPrice({
    Key? key,
    required this.value,
    this.style,
    this.showPrefix = false,
  }) : super(key: key);

  @override
  State<AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<AnimatedPrice> {
  late double oldValue;

  @override
  void initState() {
    super.initState();
    oldValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedPrice oldWidget) {
    if (widget.value != oldWidget.value) {
      oldValue = oldWidget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: oldValue, end: widget.value),
      duration: const Duration(milliseconds: 280),
      builder: (context, animatedValue, child) {
        return Text(
          '${widget.showPrefix ? 'от ' : ''}${animatedValue.round()} ₽',
          style: widget.style ?? Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
