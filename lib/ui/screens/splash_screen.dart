import 'package:flutter/material.dart';
import 'orders/home_screen.dart'; // импортируйте свой файл с HomeScreen
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
  bool _hasNavigated = false; // Флаг для предотвращения повторной навигации

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
          // После загрузки данных выполняем навигацию
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToHome();
          });
          return _buildSplashScreen();
        } else if (snapshot.hasError) {
          // Обработка ошибки с кнопкой для повторной попытки загрузки данных
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
          // Пока данные загружаются, показываем экран загрузки
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
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
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
