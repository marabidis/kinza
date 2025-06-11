import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/features/orders/presentation/screens/home_screen.dart';

import '../widgets/dots_loader.dart';

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
