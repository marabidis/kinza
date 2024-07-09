import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_item.dart';
import 'ui/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config.dart';
import '../services/api_client.dart'; // Убедитесь, что импортировали api_client.dart

void main() async {
  // Обеспечиваем инициализацию
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка конфигурационных данных
  await dotenv.load(fileName: ".env");

  final apiUrl = dotenv.env['API_URL'];
  final apiKey = dotenv.env['API_KEY'];

  // Инициализация timezone
  tz.initializeTimeZones();
  // tz.setLocalLocation(tz.getLocation('Europe/Saratov'))

  // DateTime.now()
  initializeDateFormatting('ru_RU');

  // Установка предпочитаемой ориентации
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    // Регистрация адаптера перед инициализацией Hive
    await Hive.initFlutter();
    Hive.registerAdapter(CartItemAdapter());

    final apiClient = ApiClient(); // Инициализация ApiClient

    runApp(MyApp(apiClient: apiClient));
  });
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  MyApp({required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: SplashScreen(apiClient: apiClient),
        ),
      ),
    );
  }
}
