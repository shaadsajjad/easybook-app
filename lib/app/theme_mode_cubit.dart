import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Which theme the app uses: follow the phone (default), always light or
/// always dark. App-level (like AuthBloc) because MaterialApp reads it.
/// The Appearance option on the Profile page changes it.
class ThemeModeCubit extends Cubit<ThemeMode> {
  new() : super(ThemeMode.system);

  void select(ThemeMode mode) => emit(mode);
}
