import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kinza/core/constants/config.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/core/theme/app_theme.dart';
import 'package:kinza/core/theme/themed_system_ui.dart';
import 'package:kinza/features/splash/presentation/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await initializeDateFormatting('ru_RU');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());

  log('API_BASE_URL: ${Config.apiBaseUrl}');

  // ★ берём singleton
  final apiClient = ApiClient.instance;

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, super.key});

  final ApiClient apiClient;

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
