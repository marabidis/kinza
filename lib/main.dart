import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_item.dart';
import 'ui/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config.dart';

void main() async {
  // Обеспечиваем инициализацию
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка конфигурационных данных
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? Config.supabaseUrl;
  final supabaseAnonKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? Config.supabaseAnonKey;

  // Инициализация timezone
  tz.initializeTimeZones();
  // tz.setLocalLocation(tz.getLocation('Europe/Saratov'));

  // DateTime.now()
  initializeDateFormatting('ru_RU');

  // Установка предпочитаемой ориентации
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    // Регистрация адаптера перед инициализацией Hive
    await Hive.initFlutter();
    Hive.registerAdapter(CartItemAdapter());

    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: SplashScreen(),
        ),
      ),
    );
  }
}
