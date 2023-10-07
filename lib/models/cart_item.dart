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
  final String? imageUrl;

  @HiveField(5)
  final double? weight; // изменено на double

  @HiveField(6)
  final double? minimumWeight; // изменено на double

  @HiveField(7)
  final bool isWeightBased; // новое свойство

  @HiveField(8)
  final String? unit; // единица измерения (например, 'г', 'кг', 'л' и т. д.)

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.weight,
    this.minimumWeight,
    required this.isWeightBased, // новый параметр
    this.unit,
  });
}
