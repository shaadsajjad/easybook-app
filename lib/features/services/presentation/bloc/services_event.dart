part of 'services_bloc.dart';

sealed class ServicesEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Home opened: load the first page.
final class ServicesStarted extends ServicesEvent {
  const new();
}

/// The search box changed (debounced in the bloc).
final class ServicesSearchChanged extends ServicesEvent {
  const new(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// A category chip was tapped. `null` is "All".
final class ServicesCategorySelected extends ServicesEvent {
  const new(this.category);

  final String? category;

  @override
  List<Object?> get props => [category];
}

/// The price filter sheet was applied (or reset with nulls).
final class ServicesPriceRangeChanged extends ServicesEvent {
  const new({this.minPrice, this.maxPrice});

  final double? minPrice;
  final double? maxPrice;

  @override
  List<Object?> get props => [minPrice, maxPrice];
}

/// Remove search, category and price filters at once.
final class ServicesFiltersCleared extends ServicesEvent {
  const new();
}

/// The list was scrolled near the end.
final class ServicesNextPageRequested extends ServicesEvent {
  const new();
}

/// Pull to refresh, or "Try again".
final class ServicesRefreshed extends ServicesEvent {
  const new();
}
