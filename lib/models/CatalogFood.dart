import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CatalogFood {
  final SupabaseClient supabase;
  CatalogFood(this.supabase);

  // String? category;
  String? name_item;
  int? price;
  String? category;
  // Метод для получения продуктов по заданной категории
  Future<List<Map<String, dynamic>>> fetchFoodItemsByCategory(
      String category) async {
    final response = await supabase.from('kinzas').select('*').execute();

    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
