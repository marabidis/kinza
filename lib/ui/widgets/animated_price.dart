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
    final style = widget.style ?? Theme.of(context).textTheme.titleMedium;
    // Максимально длинная строка, например, "от 99999 ₽"
    final maxPriceString =
        '${widget.showPrefix ? 'от ' : ''}99999 ₽'; // подбери длину под свой магазин

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: oldValue, end: widget.value),
      duration: const Duration(milliseconds: 280),
      builder: (context, animatedValue, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // "Призрак" самой длинной строки — для резерва ширины
            Opacity(
              opacity: 0.0,
              child: Text(
                maxPriceString,
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
            // Основной анимируемый текст
            Text(
              '${widget.showPrefix ? 'от ' : ''}${animatedValue.round()} ₽',
              style: style,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
