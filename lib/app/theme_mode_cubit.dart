import 'package:bloc/bloc.dart';

/// The user's appearance choice. Plain Dart (no Flutter import), so the
/// cubit stays UI-free; `App` maps it to Flutter's `ThemeMode`.
enum AppThemeMode { system, light, dark }

/// Which theme the app uses: follow the phone (default), always light or
/// always dark. App-level (like AuthBloc) because MaterialApp reads it.
/// The Appearance option on the Profile page changes it.
class ThemeModeCubit extends Cubit<AppThemeMode> {
  new() : super(AppThemeMode.system);

  void select(AppThemeMode mode) => emit(mode);
}
