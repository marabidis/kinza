import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimezoneHelper {
  // Инициализация временной зоны
  static void initializeTimeZones() {
    tz.initializeTimeZones();
  }

  // Получение времени в Самаре из UTC
  static DateTime convertUtcToLocal(DateTime utcTime) {
    final samara = tz.getLocation('Europe/Samara');
    return tz.TZDateTime.from(utcTime, samara);
  }

  // Если вам нужно будет преобразовать локальное время в UTC, вы можете добавить такой метод:
  // static DateTime convertLocalToUtc(DateTime localTime) {
  //     final samara = tz.getLocation('Europe/Samara');
  //     return tz.TZDateTime.utc(localTime.year, localTime.month, localTime.day, localTime.hour, localTime.minute);
  // }
}
