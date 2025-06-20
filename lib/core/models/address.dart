import 'package:hive/hive.dart';

part 'address.g.dart';

@HiveType(typeId: 3)
class Address extends HiveObject {
  @HiveField(0)
  final int id; // Strapi id
  @HiveField(1)
  final String type; // home / work / other
  @HiveField(2)
  final String street;
  @HiveField(3)
  final String house;
  @HiveField(4)
  final String? flat;
  @HiveField(5)
  final String? comment;
  @HiveField(6)
  final double? lat;
  @HiveField(7)
  final double? lng;
  @HiveField(8)
  final bool isDefault;

  Address({
    required this.id,
    required this.type,
    required this.street,
    required this.house,
    this.flat,
    this.comment,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> j) {
    final a = j['attributes'] ?? j;
    return Address(
      id: j['id'] as int,
      type: a['type'] as String,
      street: a['street'] as String,
      house: a['house'] as String,
      flat: a['flat'] as String?,
      comment: a['comment'] as String?,
      lat: (a['lat'] as num?)?.toDouble(),
      lng: (a['lng'] as num?)?.toDouble(),
      isDefault: a['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'street': street,
    'house': house,
    if (flat != null) 'flat': flat,
    if (comment != null) 'comment': comment,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    'isDefault': isDefault,
  };
}
