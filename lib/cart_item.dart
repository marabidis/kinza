import 'package:hive/hive.dart';

part 'cart_item.g.dart'; // Hive будет генерировать код в этот файл

@HiveType(typeId: 0)
class CartItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int price;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final String? imageUrl; // Добавлено поле imageUrl

  @HiveField(5)
  final String? weight; // Добавлено поле weight

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.weight,
    required this.quantity,
    this.imageUrl,
  });
}
