import 'package:flutter_test/flutter_test.dart';
import 'package:app_fresh_track/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fresh_track/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    
    // Auth repo streams need to return something
    when(() => mockAuthRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.currentUser).thenReturn(null);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
        child: const PureCheckApp(),
      ),
    );

    // Verify that login screen is shown
    expect(find.text('PureCheck Login'), findsOneWidget);
  });
}
