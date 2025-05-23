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
  final String? thumbnailUrl;

  @HiveField(5)
  final double? weight;

  @HiveField(6)
  final double? minimumWeight;

  @HiveField(7)
  final bool isWeightBased;

  @HiveField(8)
  final String? unit;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    this.thumbnailUrl,
    this.weight,
    this.minimumWeight,
    required this.isWeightBased,
    this.unit,
  });

  CartItem copyWith({
    String? id,
    String? title,
    int? price,
    int? quantity,
    String? thumbnailUrl,
    double? weight,
    double? minimumWeight,
    bool? isWeightBased,
    String? unit,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      weight: weight ?? this.weight,
      minimumWeight: minimumWeight ?? this.minimumWeight,
      isWeightBased: isWeightBased ?? this.isWeightBased,
      unit: unit ?? this.unit,
    );
  }
}
