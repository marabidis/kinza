import 'package:flutter/material.dart';
import 'orders/home_screen.dart'; // импортируйте свой файл с HomeScreen
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:rive/rive.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _loadingData;

  @override
  void initState() {
    super.initState();
    _loadingData = _loadData();
  }

  Future<void> _loadData() async {
    // Здесь ваш код для загрузки данных...
    await Future.delayed(Duration(seconds: 2)); // Имитация задержки
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Данные загружены и готовы к использованию
          _navigateToHome();
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo_kinza.svg',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text("Сейчас будет вкусно!"),
                ],
              ),
            ),
          );
        } else {
          // Данные еще загружаются
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo_kinza.svg',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(), // Индикатор загрузки
                ],
              ),
            ),
          );
        }
      },
    );
  }

  _navigateToHome() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }
}
