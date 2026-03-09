class FilterState {
  final String searchQuery;
  final String selectedCategory;

  const FilterState({this.searchQuery = '', this.selectedCategory = 'All'});

  FilterState copyWith({String? searchQuery, String? selectedCategory}) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
