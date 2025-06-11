// lib/models/ingredient.dart

import 'product.dart'; // для ImageUrl

class Ingredient {
  final int id;
  final String name;
  final ImageUrl? photo;

  const Ingredient({
    required this.id,
    required this.name,
    this.photo,
  });

  static const empty = Ingredient(id: 0, name: '', photo: null);

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    final attrs = map['attributes'] ?? {};

    // Поправили парсинг фото (может быть List или Map)
    ImageUrl? parsedPhoto;
    final photoData = attrs['photo']?['data'];
    if (photoData is List && photoData.isNotEmpty) {
      parsedPhoto = ImageUrl.fromMap(photoData.first['attributes']);
    } else if (photoData is Map && photoData['attributes'] != null) {
      parsedPhoto = ImageUrl.fromMap(photoData['attributes']);
    }

    return Ingredient(
      id: map['id'] as int,
      name: attrs['name'] ?? '',
      photo: parsedPhoto,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'photo': photo?.toMap(),
      };
}
