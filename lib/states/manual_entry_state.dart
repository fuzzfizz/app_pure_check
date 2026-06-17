class ManualEntryState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ManualEntryState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ManualEntryState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSuccess,
  }) {
    return ManualEntryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
