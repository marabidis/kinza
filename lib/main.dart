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
import '../services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env config
  await dotenv.load(fileName: "assets/.env");

  // Initialize timezones and date formatting
  tz.initializeTimeZones();
  await initializeDateFormatting('ru_RU');

  // Set device orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());

  // Run the app
  final apiClient = ApiClient();
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SplashScreen(apiClient: apiClient),
      ),
    );
  }
}
