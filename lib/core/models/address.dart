// lib/core/models/address.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'address.g.dart'; // генерируется командой build_runner

/// Тип адреса
@HiveType(typeId: 30)
enum AddressType {
  @HiveField(0)
  home,
  @HiveField(1)
  work,
  @HiveField(2)
  other;

  /// Для API: преобразование enum → строка
  String get api => name;

  /// Короткая подпись
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

  /// Преобразование строки из API → enum
  static AddressType fromApi(String? v) {
    return AddressType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AddressType.other,
    );
  }
}

/// Модель адреса
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

  /// «Дом» / «Работа» / «Другое»
  String get typeLabel => type.label;

  /// «Улица, дом, кв.»
  String get fullLine {
    final buf = StringBuffer('$street, $house');
    if (flat != null && flat!.trim().isNotEmpty) {
      buf.write(', кв. $flat');
    }
    return buf.toString();
  }

  /// Создание из JSON-ответа Strapi
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

  /// Сериализация для Strapi
  Map<String, dynamic> toJson() {
    return {
      'type': type.api,
      'street': street,
      'house': house,
      'isDefault': isDefault,
      if (flat != null) 'flat': flat,
      if (comment != null) 'comment': comment,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  /// Копирование с изменениями
  Address copyWith({
    int? id,
    AddressType? type,
    String? street,
    String? house,
    String? flat,
    String? comment,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      street: street ?? this.street,
      house: house ?? this.house,
      flat: flat ?? this.flat,
      comment: comment ?? this.comment,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() =>
      'Address($id, ${type.label}, $fullLine${flat != null ? ", кв. $flat" : ""})';
}
