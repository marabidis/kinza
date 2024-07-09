// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class Product {
  final ImageUrl? imageUrl;
  final String blurHash;
  final String title;
  final String description;
  final String category;
  final int price;
  final int id;
  final double? weight;
  final double? minimumWeight;
  final bool? isWeightBased;
  final String? mark;

  Product({
    this.imageUrl,
    required this.blurHash,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.id,
    this.weight,
    this.minimumWeight,
    this.isWeightBased,
    this.mark,
  });

  Product copyWith({
    ImageUrl? imageUrl,
    String? blurHash,
    String? title,
    String? description,
    String? category,
    int? price,
    int? id,
    double? weight,
    double? minimumWeight,
    bool? isWeightBased,
    String? mark,
  }) {
    return Product(
      imageUrl: imageUrl ?? this.imageUrl,
      blurHash: blurHash ?? this.blurHash,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      id: id ?? this.id,
      weight: weight ?? this.weight,
      minimumWeight: minimumWeight ?? this.minimumWeight,
      isWeightBased: isWeightBased ?? this.isWeightBased,
      mark: mark ?? this.mark,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imageUrl': imageUrl?.toMap(),
      'blurHash': blurHash,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'id': id,
      'weight': weight,
      'minimumWeight': minimumWeight,
      'isWeightBased': isWeightBased,
      'mark': mark,
    };
  }

  factory Product.fromMap(Map<String, dynamic> item) {
    final attributes = item['attributes'] as Map<String, dynamic>? ?? {};
    final int id = item['id'] as int? ?? 0;
    final imageUrlData = attributes['ImageUrl'] != null
        ? (attributes['ImageUrl']['data']['attributes']
            as Map<String, dynamic>?)
        : null;

    // Печать данных перед передачей их в ImageUrl.fromMap
    print('Data before ImageUrl.fromMap: $imageUrlData');

    final imageUrl =
        imageUrlData != null ? ImageUrl.fromMap(imageUrlData) : null;

    return Product(
      imageUrl: imageUrl,
      blurHash: attributes['blurHash'] ?? '',
      title: attributes['name_item'] ?? '',
      description: attributes['description_item'] ?? '',
      category: attributes['category'] ?? '',
      price: attributes['price'] as int? ?? 0,
      id: id,
      weight: (attributes['weight'] as num?)?.toDouble(),
      minimumWeight: (attributes['minimumWeight'] as num?)?.toDouble(),
      isWeightBased: attributes['isWeightBased'] as bool? ?? false,
      mark: attributes['mark'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(imageUrl: $imageUrl, blurHash: $blurHash, title: $title, description: $description, category: $category, price: $price, id: $id, mark: $mark)';
  }

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.imageUrl == imageUrl &&
        other.blurHash == blurHash &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.price == price &&
        other.id == id &&
        other.mark == mark;
  }

  @override
  int get hashCode {
    return imageUrl.hashCode ^
        blurHash.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        price.hashCode ^
        id.hashCode ^
        mark.hashCode;
  }
}

class ImageUrl {
  final String url;
  final String thumbnailUrl;
  final String mediumUrl; // Добавьте это поле
  final String blurHash;
  final String name;
  final int width;
  final int height;
  final Map<String, dynamic> formats;

  ImageUrl({
    required this.url,
    required this.thumbnailUrl,
    required this.mediumUrl, // И это
    required this.blurHash,
    required this.name,
    required this.width,
    required this.height,
    required this.formats,
  });

  factory ImageUrl.fromMap(Map<String, dynamic> map) {
    final formatsMap = map['formats'] as Map<String, dynamic>? ?? {};
    final smallMap = formatsMap['small'] as Map<String, dynamic>? ?? {};
    final mediumMap =
        formatsMap['medium'] as Map<String, dynamic>? ?? {}; // И это

    final String smallUrl = smallMap['url'] as String? ?? '';
    final String mediumUrl = mediumMap['url'] as String? ?? ''; // И это

    return ImageUrl(
      url: map['url'] as String? ?? '',
      thumbnailUrl: smallUrl,
      mediumUrl: mediumUrl, // И это
      blurHash: map['blurhash'] as String? ?? '',
      name: map['name'] as String? ?? '',
      width: map['width'] as int? ?? 0,
      height: map['height'] as int? ?? 0,
      formats: formatsMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'mediumUrl': mediumUrl, // И это
      'blurHash': blurHash,
      'name': name,
      'width': width,
      'height': height,
      'formats': formats,
    };
  }

  @override
  String toString() {
    return 'ImageUrl(url: $url, thumbnailUrl: $thumbnailUrl, mediumUrl: $mediumUrl, blurHash: $blurHash, name: $name, width: $width, height: $height, formats: $formats)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageUrl &&
        other.url == url &&
        other.thumbnailUrl == thumbnailUrl &&
        other.mediumUrl == mediumUrl && // И это
        other.blurHash == blurHash &&
        other.name == name &&
        other.width == width &&
        other.height == height &&
        other.formats == formats;
  }

  @override
  int get hashCode {
    return url.hashCode ^
        thumbnailUrl.hashCode ^
        mediumUrl.hashCode ^ // И это
        blurHash.hashCode ^
        name.hashCode ^
        width.hashCode ^
        height.hashCode ^
        formats.hashCode;
  }
}
