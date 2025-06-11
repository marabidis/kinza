import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/services/api_client.dart';
import '../../../ui/screens/orders/home_screen.dart';

/// Экран-заставка с логотипом и бегущими точками.
/// После [duration] переходим на HomeScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.apiClient,
    this.duration = const Duration(seconds: 2),
  });

  final ApiClient apiClient;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/*───────────────────────────────────────────────────────────────────*/
class _SplashScreenState extends State<SplashScreen> {
  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();

    // Параллельно можно добавить инициализацию Remote Config / pre-cache
    _loadingFuture = Future.delayed(widget.duration).then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'home'),
          builder: (_) => HomeScreen(apiClient: widget.apiClient),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: cs.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo_kinza.svg',
                    height: 100,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 20),
                  Text('Сейчас будет вкусно!', style: txt.titleLarge),
                  const SizedBox(height: 14),
                  const DotsLoader(), // отдельный виджет анимации точек
                ],
              ),
            ),
          );
        }
        // Навигация уже запущена — просто ничего не рендерим
        return const SizedBox.shrink();
      },
    );
  }
}

/*───────────────────────────────────────────────────────────────────*/
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
