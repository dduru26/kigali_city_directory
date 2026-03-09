import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_state.dart';

final filterControllerProvider =
    StateNotifierProvider<FilterController, FilterState>((ref) {
      return FilterController();
    });

class FilterController extends StateNotifier<FilterState> {
  FilterController() : super(const FilterState());

  void updateSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void updateCategory(String value) {
    state = state.copyWith(selectedCategory: value);
  }

  void clearFilters() {
    state = const FilterState();
  }
}
