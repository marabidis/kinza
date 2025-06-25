// lib/services/telegram_service.dart

import 'package:http/http.dart' as http;
import 'package:kinza/core/constants/config.dart';

Future<void> sendOrderToTelegram(String orderDetails) async {
  await http.post(
    Uri.parse(
        'https://api.telegram.org/bot${Config.telegramBotToken}/sendMessage'),
    body: {
      'chat_id': Config.telegramChatId,
      'text': orderDetails,
      'parse_mode': 'Markdown'
    },
  );
}
