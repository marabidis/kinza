import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeService {
  static void initializeTimeZones() {
    tz.initializeTimeZones();
  }

  static String getCurrentTime() {
    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.getLocation('Europe/Samara'));
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'ru_RU');
    return formatter.format(now.subtract(const Duration(hours: 1)));
  }
}
