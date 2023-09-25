// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Product {
  final String? imageUrl;
  final String blurHash;
  final String title;
  final String description;
  final String category;
  final int price;
  final String id;

  Product({
    this.imageUrl,
    required this.blurHash,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.id,
  });

  Product copyWith({
    String? imageUrl,
    String? blurHash,
    String? title,
    String? description,
    String? category,
    int? price,
    String? id,
  }) {
    return Product(
      imageUrl: imageUrl ?? this.imageUrl,
      blurHash: blurHash ?? this.blurHash,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imageUrl': imageUrl,
      'blurHash': blurHash,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'id': id,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      blurHash: map['blurHash'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: map['price'] as int,
      id: map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(imageUrl: $imageUrl, blurHash: $blurHash, title: $title, description: $description, category: $category, price: $price, id: $id)';
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
        other.id == id;
  }

  @override
  int get hashCode {
    return imageUrl.hashCode ^
        blurHash.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        price.hashCode ^
        id.hashCode;
  }
}