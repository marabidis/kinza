import 'package:flutter/material.dart';

/// Три бегущие точки с лёгким тактильным откликом.
class DotsLoader extends StatefulWidget {
  const DotsLoader({super.key});

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _dotCount;
  int _lastDot = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _dotCount = StepTween(begin: 1, end: 3).animate(_controller)
      ..addListener(_maybeFeedback);
  }

  void _maybeFeedback() {
    if (_dotCount.value != _lastDot) {
      _lastDot = _dotCount.value;
      Feedback.forTap(context); // уважает системные настройки вибрации/звука
    }
  }

  @override
  void dispose() {
    _dotCount.removeListener(_maybeFeedback);
    _controller
      ..stop()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (_, __) {
        final dots = '.' * _dotCount.value;
        return Semantics(
          label: 'Загружаем меню$dots',
          excludeSemantics: true,
          child: Text(
            dots,
            style: TextStyle(
              fontSize: 32,
              letterSpacing: 1,
              color: cs.primary,
            ),
          ),
        );
      },
    );
  }
}
