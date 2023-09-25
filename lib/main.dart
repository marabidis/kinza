import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Это необходимо для установки ориентации
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cart_item.dart';
import 'ui/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // Задаем вертикальную ориентацию для приложения
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация timezone
  tz.initializeTimeZones();
  // tz.setLocalLocation(tz.getLocation('Europe/Saratov'));

  // DateTime.now()

  initializeDateFormatting('ru_RU');

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    await Supabase.initialize(
      url: 'https://yxsrcgwplogjoecppegy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4c3JjZ3dwbG9nam9lY3BwZWd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMzMTIzNjIsImV4cCI6MjAwODg4ODM2Mn0.B3QQwk4SmbkIWmVicbkX70BvxxTry9MQRd3EwjYl9AU',
    );

    // Регистрация адаптера перед инициализацией Hive
    Hive.registerAdapter(CartItemAdapter());

    await Hive.initFlutter();

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
