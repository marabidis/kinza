// lib/core/models/product.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'ingredient_option.dart';

class Product {
  final ImageUrl? imageUrl;
  final String blurHash;
  final String title;
  final String description;
  final String category;
  final int price;
  final int? discountPrice; // новое поле (старая цена)
  final int id;
  final double? weight;
  final double? minimumWeight;
  final bool? isWeightBased;
  final String? mark;
  final List<IngredientOption> ingredientOptions;

  const Product({
    this.imageUrl,
    required this.blurHash,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.id,
    this.weight,
    this.minimumWeight,
    this.isWeightBased,
    this.mark,
    this.ingredientOptions = const [],
  });

  /*────────────────── copyWith ──────────────────*/
  Product copyWith({
    ImageUrl? imageUrl,
    String? blurHash,
    String? title,
    String? description,
    String? category,
    int? price,
    int? discountPrice,
    int? id,
    double? weight,
    double? minimumWeight,
    bool? isWeightBased,
    String? mark,
    List<IngredientOption>? ingredientOptions,
  }) =>
      Product(
        imageUrl: imageUrl ?? this.imageUrl,
        blurHash: blurHash ?? this.blurHash,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        price: price ?? this.price,
        discountPrice: discountPrice ?? this.discountPrice,
        id: id ?? this.id,
        weight: weight ?? this.weight,
        minimumWeight: minimumWeight ?? this.minimumWeight,
        isWeightBased: isWeightBased ?? this.isWeightBased,
        mark: mark ?? this.mark,
        ingredientOptions: ingredientOptions ?? this.ingredientOptions,
      );

  /*────────────────── toMap / toJson ─────────────*/
  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl?.toMap(),
        'blurHash': blurHash,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'discountPrice': discountPrice, // camelCase ↔ Strapi
        'id': id,
        'weight': weight,
        'minimumWeight': minimumWeight,
        'isWeightBased': isWeightBased,
        'mark': mark,
        'ingredientOptions': ingredientOptions.map((e) => e.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());

  /*────────────────── fromMap / fromJson ─────────*/
  factory Product.fromMap(Map<String, dynamic> item) {
    final attrs = item['attributes'] as Map<String, dynamic>? ?? {};
    final id = item['id'] as int? ?? 0;

    // image
    final imgData =
        attrs['ImageUrl']?['data']?['attributes'] as Map<String, dynamic>?;
    final imageUrl = imgData != null ? ImageUrl.fromMap(imgData) : null;

    // ingredient options
    final optionsData = (attrs['ingredient_options']?['data'] as List?) ?? [];
    final options = optionsData
        .map((e) => IngredientOption.fromMap(e as Map<String, dynamic>))
        .toList();

    // ⚠️  discountPrice может прийти и в camelCase, и в snake_case.
    final rawDiscount = attrs['discountPrice'] ?? attrs['discount_price'];

    return Product(
      imageUrl: imageUrl,
      blurHash: attrs['blurHash'] ?? '',
      title: attrs['name_item'] ?? '',
      description: attrs['description_item'] ?? '',
      category: attrs['category'] ?? '',
      price: attrs['price'] as int? ?? 0,
      discountPrice: (rawDiscount as num?)?.toInt(),
      id: id,
      weight: (attrs['weight'] as num?)?.toDouble(),
      minimumWeight: (attrs['minimumWeight'] as num?)?.toDouble(),
      isWeightBased: attrs['isWeightBased'] as bool? ?? false,
      mark: attrs['mark'],
      ingredientOptions: options,
    );
  }

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  @override
  String toString() =>
      'Product(id: $id, title: $title, price: $price, discountPrice: $discountPrice)';
}

/*────────────────── ImageUrl ─────────────────────*/
class ImageUrl {
  final String url;
  final String thumbnailUrl;
  final String mediumUrl;
  final String blurHash;
  final String name;
  final int width;
  final int height;
  final Map<String, dynamic> formats;

  const ImageUrl({
    required this.url,
    required this.thumbnailUrl,
    required this.mediumUrl,
    required this.blurHash,
    required this.name,
    required this.width,
    required this.height,
    required this.formats,
  });

  factory ImageUrl.fromMap(Map<String, dynamic> map) {
    final fmts = map['formats'] as Map<String, dynamic>? ?? {};

    final thumb =
        (fmts['thumbnail'] ?? fmts['small']) as Map<String, dynamic>? ?? {};
    final medium = fmts['medium'] as Map<String, dynamic>? ?? {};

    final url = map['url'] ?? '';
    return ImageUrl(
      url: url,
      thumbnailUrl: thumb['url'] ?? url,
      mediumUrl: medium['url'] ?? url,
      blurHash: map['blurhash'] ?? '',
      name: map['name'] ?? '',
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      formats: fmts,
    );
  }

  Map<String, dynamic> toMap() => {
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'mediumUrl': mediumUrl,
        'blurHash': blurHash,
        'name': name,
        'width': width,
        'height': height,
        'formats': formats,
      };

  @override
  String toString() => 'ImageUrl(url: $url)';
}
