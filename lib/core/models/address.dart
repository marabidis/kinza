import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'address.g.dart';

/// Тип адреса
@HiveType(typeId: 30)
enum AddressType {
  @HiveField(0)
  home,
  @HiveField(1)
  work,
  @HiveField(2)
  other;

  String get label {
    switch (this) {
      case AddressType.home:
        return 'Дом';
      case AddressType.work:
        return 'Работа';
      case AddressType.other:
      default:
        return 'Другое';
    }
  }

  static AddressType fromApi(String? v) => AddressType.values.firstWhere(
    (e) => e.name == v,
    orElse: () => AddressType.other,
  );

  String get api => name;
}

@immutable
@HiveType(typeId: 31)
class Address {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final AddressType type;
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

  const Address({
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

  String get typeLabel => type.label;

  String get fullLine {
    final buf = StringBuffer('$street, $house');
    if (flat != null && flat!.trim().isNotEmpty) {
      buf.write(', кв. $flat');
    }
    return buf.toString();
  }

  factory Address.fromJson(Map<String, dynamic> j) {
    final a = j['attributes'] as Map<String, dynamic>? ?? j;
    return Address(
      id: j['id'] as int,
      type: AddressType.fromApi(a['type'] as String?),
      street: a['street'] as String,
      house: a['house'] as String,
      flat: a['flat'] as String?,
      comment: a['comment'] as String?,
      lat: (a['lat'] as num?)?.toDouble(),
      lng: (a['lng'] as num?)?.toDouble(),
      isDefault: a['isDefault'] as bool? ?? false,
    );
  }

  /// Собираем JSON для Strapi; userId подставляется в сервисе
  Map<String, dynamic> toJson({int? userId}) {
    final m = <String, dynamic>{
      'type': type.api,
      'street': street,
      'house': house,
      'isDefault': isDefault,
      if (flat != null) 'flat': flat,
      if (comment != null) 'comment': comment,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
    if (userId != null) {
      m['user'] = userId;
    }
    return m;
  }
}
