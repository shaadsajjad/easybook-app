import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/usecases/get_categories.dart';
import 'package:equatable/equatable.dart';

enum CategoriesStatus { initial, loading, success, failure }

class CategoriesState extends Equatable {
  const new({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.failure,
  });

  final CategoriesStatus status;
  final List<String> categories;
  final Failure? failure;

  @override
  List<Object?> get props => [status, categories, failure];
}

/// The category chips on Home.
class CategoriesCubit extends Cubit<CategoriesState> {
  new({required this._getCategories}) : super(const CategoriesState());

  final GetCategories _getCategories;

  Future<void> load() async {
    emit(
      CategoriesState(
        status: CategoriesStatus.loading,
        categories: state.categories,
      ),
    );
    final result = await _getCategories();
    emit(
      result.fold(
        (failure) =>
            CategoriesState(status: CategoriesStatus.failure, failure: failure),
        (categories) => CategoriesState(
          status: CategoriesStatus.success,
          categories: categories,
        ),
      ),
    );
  }
}
