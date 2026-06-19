import '../models/master_product.dart';
import '../models/analysis_model.dart';

class ScannerState {
  final bool isScanning;
  final bool isProcessing;
  final String? error;
  final String? scannedBarcode;
  final MasterProduct? foundProduct;
  final bool shouldRouteToManualEntry;
  final bool shouldRouteToProductReview;
  final bool shouldRouteToAnalysis;
  final AnalysisModel? analysisResult;
  final Map<String, dynamic>? prefilledData;

  const ScannerState({
    this.isScanning = true,
    this.isProcessing = false,
    this.error,
    this.scannedBarcode,
    this.foundProduct,
    this.shouldRouteToManualEntry = false,
    this.shouldRouteToProductReview = false,
    this.shouldRouteToAnalysis = false,
    this.analysisResult,
    this.prefilledData,
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
    bool? shouldRouteToAnalysis,
    AnalysisModel? analysisResult,
    Map<String, dynamic>? prefilledData,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      foundProduct: clearFoundProduct ? null : (foundProduct ?? this.foundProduct),
      shouldRouteToManualEntry: shouldRouteToManualEntry ?? false,
      shouldRouteToProductReview: shouldRouteToProductReview ?? false,
      shouldRouteToAnalysis: shouldRouteToAnalysis ?? false,
      analysisResult: analysisResult ?? this.analysisResult,
      prefilledData: prefilledData,
    );
  }
}
