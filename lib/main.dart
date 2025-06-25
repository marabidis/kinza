// lib/main.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kinza/core/constants/config.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/core/theme/app_theme.dart';
import 'package:kinza/core/theme/themed_system_ui.dart';
import 'package:kinza/features/splash/presentation/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Таймзоны и локализация
  tz.initializeTimeZones();
  await initializeDateFormatting('ru_RU');

  // Только портрет
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Инициализация Hive
  await Hive.initFlutter();

  // Регистрируем адаптеры
  Hive
    ..registerAdapter(AddressTypeAdapter())
    ..registerAdapter(AddressAdapter())
    ..registerAdapter(CartItemAdapter());

  // Открываем боксы ДО запуска UI
  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<Address>('addresses');

  log('API_BASE_URL: ${Config.apiBaseUrl}');
  runApp(MyApp(apiClient: ApiClient.instance));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({required this.apiClient, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinza',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: ThemedSystemUI(child: SplashScreen(apiClient: apiClient)),
    );
  }
}
