import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/app/theme_mode_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('follows the phone by default', () {
    expect(ThemeModeCubit().state, AppThemeMode.system);
  });

  blocTest<ThemeModeCubit, AppThemeMode>(
    'select switches to the picked mode',
    build: ThemeModeCubit.new,
    act: (cubit) => cubit
      ..select(AppThemeMode.dark)
      ..select(AppThemeMode.light),
    expect: () => [AppThemeMode.dark, AppThemeMode.light],
  );
}
