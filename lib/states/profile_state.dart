import '../models/profile_model.dart';
import '../models/ingredient_model.dart';

class ProfileState {
  final UserProfile? profile;
  final List<Ingredient> userAllergens;
  final List<Ingredient> allIngredients;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profile,
    this.userAllergens = const [],
    this.allIngredients = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    List<Ingredient>? userAllergens,
    List<Ingredient>? allIngredients,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      userAllergens: userAllergens ?? this.userAllergens,
      allIngredients: allIngredients ?? this.allIngredients,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
