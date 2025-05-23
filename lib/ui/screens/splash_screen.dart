import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для вибрации!
import 'orders/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/services/api_client.dart';

class SplashScreen extends StatefulWidget {
  final ApiClient apiClient;

  const SplashScreen({Key? key, required this.apiClient}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _loadingData;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _loadingData = _loadData();
  }

  Future<void> _loadData() async {
    // Здесь ваш код для загрузки данных...
    await Future.delayed(const Duration(seconds: 2)); // Имитация задержки
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToHome();
          });
          return _buildSplashScreen();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadingData = _loadData();
                      });
                    },
                    child: const Text('Повторить попытку'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Здесь кастомная анимация загрузки
          return _buildLoadingScreen();
        }
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo_kinza.svg',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text("Сейчас будет вкусно!"),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo_kinza.svg',
              height: 100,
            ),
            const SizedBox(height: 28),
            const Text(
              "Загружаем меню",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            const _AnimatedDots(),
          ],
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (!_hasNavigated) {
      _hasNavigated = true;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(apiClient: widget.apiClient),
          ),
        );
      }
    }
  }
}

/// Кастомный лоадер с точками и микро-вибрацией на каждом шаге
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dots;
  int _lastValue = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _dots = StepTween(begin: 1, end: 3).animate(_controller)
      ..addListener(_maybeVibrate);
  }

  void _maybeVibrate() {
    // Вибрация только если изменилось количество точек (шаг анимации)
    if (_dots.value != _lastValue) {
      _lastValue = _dots.value;
      HapticFeedback.lightImpact(); // или mediumImpact() для чуть сильнее
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dots,
      builder: (context, child) {
        String dots = '.' * _dots.value;
        return Text(
          dots,
          style: const TextStyle(
            fontSize: 32,
            letterSpacing: 1,
            color: Color(0xFFFBC02D),
          ),
        );
      },
    );
  }
}
