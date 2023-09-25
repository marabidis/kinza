import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://yxsrcgwplogjoecppegy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4c3JjZ3dwbG9nam9lY3BwZWd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMzMTIzNjIsImV4cCI6MjAwODg4ODM2Mn0.B3QQwk4SmbkIWmVicbkX70BvxxTry9MQRd3EwjYl9AU',
  );
}
