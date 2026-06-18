class Ingredient {
  final String id;
  final String name;
  final String? description;
  final List<String> commonNames;
  final bool isKnownAllergen;

  Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.commonNames = const [],
    this.isKnownAllergen = false,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      commonNames: List<String>.from(json['common_names'] ?? []),
      isKnownAllergen: json['is_known_allergen'] ?? false,
    );
  }
}

class UserAllergen {
  final String userId;
  final String ingredientId;
  final String? notes;

  UserAllergen({
    required this.userId,
    required this.ingredientId,
    this.notes,
  });

  factory UserAllergen.fromJson(Map<String, dynamic> json) {
    return UserAllergen(
      userId: json['user_id'],
      ingredientId: json['ingredient_id'],
      notes: json['notes'],
    );
  }
}
