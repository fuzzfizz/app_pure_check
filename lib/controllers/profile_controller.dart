import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../repositories/ingredient_repository.dart';
import '../repositories/auth_repository.dart';
import '../states/profile_state.dart';

final profileControllerProvider = NotifierProvider<ProfileController, ProfileState>(() {
  return ProfileController();
});

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _profileRepo;
  late final IngredientRepository _ingredientRepo;
  
  @override
  ProfileState build() {
    _profileRepo = ref.watch(profileRepositoryProvider);
    _ingredientRepo = ref.watch(ingredientRepositoryProvider);
    
    Future.microtask(_init);
    return ProfileState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Not authenticated');
        return;
      }

      final profile = await _profileRepo.getUserProfile(user.id);
      final allergens = await _ingredientRepo.getUserAllergens(user.id);
      final allIngredients = await _ingredientRepo.getAllIngredients();

      state = state.copyWith(
        profile: profile,
        userAllergens: allergens,
        allIngredients: allIngredients,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({String? skinType, List<String>? skinConcerns}) async {
    if (state.profile == null) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedProfile = state.profile!.copyWith(
        skinType: skinType,
        skinConcerns: skinConcerns,
      );
      await _profileRepo.updateUserProfile(updatedProfile);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleAllergen(String ingredientId, bool isAdding) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (isAdding) {
        await _ingredientRepo.addUserAllergen(user.id, ingredientId);
      } else {
        await _ingredientRepo.removeUserAllergen(user.id, ingredientId);
      }
      // Refresh allergens
      final allergens = await _ingredientRepo.getUserAllergens(user.id);
      state = state.copyWith(userAllergens: allergens, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
