import 'package:flutter_test/flutter_test.dart';
import 'package:app_fresh_track/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FreshTrackApp()));

    // Verify that login screen is shown
    expect(find.text('FreshTrack Login'), findsOneWidget);
  });
}
