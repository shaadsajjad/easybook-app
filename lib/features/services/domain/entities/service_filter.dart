import 'package:equatable/equatable.dart';

/// What the user is searching for on Home. Every field is optional.
class ServiceFilter extends Equatable {
  const new({this.search = '', this.category, this.minPrice, this.maxPrice});

  final String search;
  final String? category;
  final double? minPrice;
  final double? maxPrice;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// True when the list is narrowed down (the featured carousel is then
  /// hidden so results come first).
  bool get isActive =>
      search.trim().isNotEmpty || category != null || hasPriceRange;

  ServiceFilter withSearch(String value) => ServiceFilter(
    search: value,
    category: category,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );

  /// `null` means "All categories".
  ServiceFilter withCategory(String? value) => ServiceFilter(
    search: search,
    category: value,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );

  ServiceFilter withPriceRange({double? min, double? max}) => ServiceFilter(
    search: search,
    category: category,
    minPrice: min,
    maxPrice: max,
  );

  @override
  List<Object?> get props => [search, category, minPrice, maxPrice];
}
