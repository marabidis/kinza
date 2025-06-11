// lib/models/ingredient_option.dart

import 'ingredient.dart';

class IngredientOption {
  final int id;
  final Ingredient ingredient;
  final bool canRemove;
  final bool canAdd;
  final bool canDouble;
  final bool isDefault;
  final int addPrice;
  final int doublePrice;

  IngredientOption({
    required this.id,
    required this.ingredient,
    required this.canRemove,
    required this.canAdd,
    required this.canDouble,
    required this.isDefault,
    required this.addPrice,
    required this.doublePrice,
  });

  factory IngredientOption.fromMap(Map<String, dynamic> map) {
    final attrs = map['attributes'] ?? {};

    // Попытка взять один ингредиент: сначала 'ingredient', потом первый из 'ingredients'
    dynamic ingredientData;
    if (attrs['ingredient']?['data'] != null) {
      ingredientData = attrs['ingredient']['data'];
    } else if (attrs['ingredients']?['data'] is List &&
        (attrs['ingredients']['data'] as List).isNotEmpty) {
      ingredientData = (attrs['ingredients']['data'] as List).first;
    } else {
      ingredientData = null;
    }

    return IngredientOption(
      id: map['id'] as int,
      ingredient: ingredientData != null
          ? Ingredient.fromMap(ingredientData)
          : Ingredient.empty,
      canRemove: attrs['canRemove'] ?? false,
      canAdd: attrs['canAdd'] ?? false,
      canDouble: attrs['canDouble'] ?? false,
      isDefault: attrs['default'] ?? false,
      addPrice: attrs['addPrice'] ?? 0,
      doublePrice: attrs['doublePrice'] ?? 0,
    );
  }
}
