import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository.dart';
import '../services/analysis_service.dart';
import '../states/scanner_state.dart';

final scannerControllerProvider = NotifierProvider<ScannerController, ScannerState>(() {
  return ScannerController();
});

class ScannerController extends Notifier<ScannerState> {
  late final ProductRepository _productRepo;
  late final AnalysisService _analysisService;

  @override
  ScannerState build() {
    _productRepo = ref.watch(productRepositoryProvider);
    _analysisService = ref.watch(analysisServiceProvider);
    return const ScannerState();
  }

  void startScanning() {
    state = state.copyWith(isScanning: true, isProcessing: false, clearError: true);
  }

  void pauseScanning() {
    state = state.copyWith(isScanning: false);
  }

  Future<void> processBarcode(String barcode) async {
    if (state.isProcessing) return;

    state = state.copyWith(
      isProcessing: true,
      isScanning: false,
      clearError: true,
      scannedBarcode: barcode,
    );

    try {
      final product = await _productRepo.getProductByBarcode(barcode);

      if (product != null) {
        state = state.copyWith(
          isProcessing: false,
          shouldRouteToProductReview: true,
          foundProduct: product,
        );
      } else {
        // Cache miss: Try fetching from OBF, then route to verification
        final externalData = await _analysisService.fetchExternalProduct(barcode);
        state = state.copyWith(
          isProcessing: false,
          shouldRouteToManualEntry: true,
          prefilledData: externalData,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        isScanning: true, // Resume scanning on error
        error: e.toString(),
      );
    }
  }
  
  void resetRouting() {
     state = state.copyWith(
       shouldRouteToManualEntry: false, 
       shouldRouteToProductReview: false,
       shouldRouteToAnalysis: false,
       clearFoundProduct: true,
     );
  }
}
