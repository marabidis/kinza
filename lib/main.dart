import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/cart_item.dart';
import 'ui/screens/splash_screen.dart';
import 'config.dart';
import 'theme/app_theme.dart';
import 'theme/themed_system_ui.dart'; // <--- добавь импорт
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  tz.initializeTimeZones();
  await initializeDateFormatting('ru_RU');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());

  final apiClient = ApiClient();
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({required this.apiClient, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinza',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // 👇 здесь обернули SplashScreen в ThemedSystemUI
      home: ThemedSystemUI(
        child: SplashScreen(apiClient: apiClient),
      ),
    );
  }
}
