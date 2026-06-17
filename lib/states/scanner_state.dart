import '../models/master_product.dart';

class ScannerState {
  final bool isScanning;
  final bool isProcessing;
  final String? error;
  final String? scannedBarcode;
  final MasterProduct? foundProduct;
  final bool shouldRouteToManualEntry;
  final bool shouldRouteToProductReview;

  const ScannerState({
    this.isScanning = true,
    this.isProcessing = false,
    this.error,
    this.scannedBarcode,
    this.foundProduct,
    this.shouldRouteToManualEntry = false,
    this.shouldRouteToProductReview = false,
  });

  ScannerState copyWith({
    bool? isScanning,
    bool? isProcessing,
    String? error,
    bool clearError = false,
    String? scannedBarcode,
    MasterProduct? foundProduct,
    bool clearFoundProduct = false,
    bool? shouldRouteToManualEntry,
    bool? shouldRouteToProductReview,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      foundProduct: clearFoundProduct ? null : (foundProduct ?? this.foundProduct),
      shouldRouteToManualEntry: shouldRouteToManualEntry ?? false,
      shouldRouteToProductReview: shouldRouteToProductReview ?? false,
    );
  }
}
