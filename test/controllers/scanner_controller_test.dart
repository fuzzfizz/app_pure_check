import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fresh_track/controllers/scanner_controller.dart';
import 'package:app_fresh_track/repositories/product_repository.dart';
import 'package:app_fresh_track/services/analysis_service.dart';
import 'package:app_fresh_track/states/scanner_state.dart';
import 'package:app_fresh_track/models/master_product.dart';

// Mock dependencies
class MockProductRepository extends Mock implements ProductRepository {}
class MockAnalysisService extends Mock implements AnalysisService {}

void main() {
  late ProviderContainer container;
  late MockProductRepository mockProductRepository;
  late MockAnalysisService mockAnalysisService;

  setUp(() {
    mockProductRepository = MockProductRepository();
    mockAnalysisService = MockAnalysisService();

    container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWith((ref) => mockProductRepository),
        analysisServiceProvider.overrideWith((ref) => mockAnalysisService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('ScannerController routes to manual entry on cache miss', () async {
    // Setup: Cache miss
    when(() => mockProductRepository.getProductByBarcode(any()))
        .thenAnswer((_) async => null);

    final scannerController = container.read(scannerControllerProvider.notifier);

    // Trigger processing
    await scannerController.processBarcode('12345');

    final state = container.read(scannerControllerProvider);
    
    // Verify
    expect(state.shouldRouteToManualEntry, isTrue);
    expect(state.shouldRouteToAnalysis, isFalse);
    expect(state.isProcessing, isFalse);
    
    // Verify AnalysisService was NOT called
    verifyNever(() => mockAnalysisService.analyzeProduct(barcode: any(named: 'barcode')));
  });
}
