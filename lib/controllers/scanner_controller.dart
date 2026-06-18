import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository.dart';
import '../states/scanner_state.dart';

final scannerControllerProvider = NotifierProvider<ScannerController, ScannerState>(() {
  return ScannerController();
});

class ScannerController extends Notifier<ScannerState> {
  late final ProductRepository _productRepo;

  @override
  ScannerState build() {
    _productRepo = ref.watch(productRepositoryProvider);
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
        state = state.copyWith(
          isProcessing: false,
          shouldRouteToManualEntry: true,
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
       clearFoundProduct: true,
     );
  }
}
