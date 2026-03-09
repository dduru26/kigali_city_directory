class ListingsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ListingsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ListingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ListingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
