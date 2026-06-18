import '../models/analysis_model.dart';

class AnalysisState {
  final bool isLoading;
  final String? error;
  final AnalysisModel? result;

  const AnalysisState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  AnalysisState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AnalysisModel? result,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: result ?? this.result,
    );
  }
}
