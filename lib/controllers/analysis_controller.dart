import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analysis_service.dart';
import '../states/analysis_state.dart';

final analysisControllerProvider = NotifierProvider<AnalysisController, AnalysisState>(() {
  return AnalysisController();
});

class AnalysisController extends Notifier<AnalysisState> {
  late final AnalysisService _analysisService;

  @override
  AnalysisState build() {
    _analysisService = ref.watch(analysisServiceProvider);
    return const AnalysisState();
  }

  Future<void> analyzeProduct({String? barcode, String? manualIngredients}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _analysisService.analyzeProduct(
        barcode: barcode,
        manualIngredients: manualIngredients,
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const AnalysisState();
  }
}
