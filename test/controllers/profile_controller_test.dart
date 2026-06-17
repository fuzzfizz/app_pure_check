import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app_fresh_track/controllers/profile_controller.dart';
import 'package:app_fresh_track/repositories/auth_repository.dart';
import 'package:app_fresh_track/repositories/profile_repository.dart';
import 'package:app_fresh_track/repositories/ingredient_repository.dart';
import 'package:app_fresh_track/models/profile_model.dart';
import 'package:app_fresh_track/models/ingredient_model.dart';
import 'package:app_fresh_track/states/profile_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockIngredientRepository extends Mock implements IngredientRepository {}
class MockUser extends Mock implements User {}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockProfileRepository mockProfileRepo;
  late MockIngredientRepository mockIngredientRepo;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockProfileRepo = MockProfileRepository();
    mockIngredientRepo = MockIngredientRepository();
    mockUser = MockUser();

    when(() => mockUser.id).thenReturn('user123');
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        profileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('ProfileController initializes correctly with valid data', () async {
    when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
    
    final fakeProfile = UserProfile(id: 'user123', email: 'test@example.com', skinType: 'oily');
    when(() => mockProfileRepo.getUserProfile('user123')).thenAnswer((_) async => fakeProfile);
    
    final fakeIngredient = Ingredient(id: 'ing1', name: 'Aloe Vera');
    when(() => mockIngredientRepo.getUserAllergens('user123')).thenAnswer((_) async => [fakeIngredient]);
    when(() => mockIngredientRepo.getAllIngredients()).thenAnswer((_) async => [fakeIngredient]);

    final container = makeProviderContainer();
    var states = <ProfileState>[];
    container.listen(
      profileControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    expect(states.first.isLoading, isTrue);

    // Wait for microtasks and async operations
    await Future.delayed(const Duration(milliseconds: 100));

    final finalState = states.last;
    expect(finalState.isLoading, isFalse);
    expect(finalState.error, isNull);
    expect(finalState.profile?.skinType, 'oily');
    expect(finalState.userAllergens.length, 1);
    expect(finalState.userAllergens.first.name, 'Aloe Vera');
  });

  test('ProfileController handles unauthenticated user during initialization', () async {
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    
    final container = makeProviderContainer();
    var states = <ProfileState>[];
    container.listen(
      profileControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    
    await Future.delayed(const Duration(milliseconds: 100));

    final finalState = states.last;
    expect(finalState.isLoading, isFalse);
    expect(finalState.error, 'Not authenticated');
    expect(finalState.profile, isNull);
  });

  test('updateProfile successfully updates data and updates state', () async {
    when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
    
    final fakeProfile = UserProfile(id: 'user123', email: 'test@example.com', skinType: 'unknown');
    when(() => mockProfileRepo.getUserProfile('user123')).thenAnswer((_) async => fakeProfile);
    when(() => mockIngredientRepo.getUserAllergens('user123')).thenAnswer((_) async => []);
    when(() => mockIngredientRepo.getAllIngredients()).thenAnswer((_) async => []);
    
    when(() => mockProfileRepo.updateUserProfile(any())).thenAnswer((_) async => {});

    final container = makeProviderContainer();
    container.listen(profileControllerProvider, (_, __) {}); // Keep alive
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    await container.read(profileControllerProvider.notifier).updateProfile(skinType: 'dry');

    final state = container.read(profileControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.profile?.skinType, 'dry');
    
    verify(() => mockProfileRepo.updateUserProfile(any(that: isA<UserProfile>().having((p) => p.skinType, 'skinType', 'dry')))).called(1);
  });
}
