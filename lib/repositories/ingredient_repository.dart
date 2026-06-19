import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ingredient_model.dart';

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(Supabase.instance.client);
});

class IngredientRepository {
  final SupabaseClient _supabase;

  IngredientRepository(this._supabase);

  Future<List<Ingredient>> getAllIngredients() async {
    try {
      final response = await _supabase.from('ingredients').select();
      return (response as List).map((e) => Ingredient.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ingredients: $e');
    }
  }

  Future<List<Ingredient>> getUserAllergens(String userId) async {
    try {
      // Junction query
      final response = await _supabase
          .from('user_allergens')
          .select('ingredients(*)')
          .eq('user_id', userId);
      
      return (response as List).map((e) => Ingredient.fromJson(e['ingredients'])).toList();
    } catch (e) {
      throw Exception('Failed to fetch user allergens: $e');
    }
  }

  Future<void> addUserAllergen(String userId, String ingredientId) async {
    try {
      await _supabase.from('user_allergens').insert({
        'user_id': userId,
        'ingredient_id': ingredientId,
      });
    } catch (e) {
      throw Exception('Failed to add allergen: $e');
    }
  }

  Future<void> removeUserAllergen(String userId, String ingredientId) async {
    try {
      await _supabase.from('user_allergens')
          .delete()
          .eq('user_id', userId)
          .eq('ingredient_id', ingredientId);
    } catch (e) {
      throw Exception('Failed to remove allergen: $e');
    }
  }

  Future<void> insertIngredient(String name, String? description, List<String> commonNames, bool isKnownAllergen) async {
    try {
      await _supabase.from('ingredients').insert({
        'name': name,
        'description': description,
        'common_names': commonNames,
        'is_known_allergen': isKnownAllergen,
        'is_verified': false, // User-submitted ingredients start unverified
      });
    } catch (e) {
      throw Exception('Failed to insert ingredient: $e');
    }
  }
}
