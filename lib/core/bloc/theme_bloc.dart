import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ThemeEvent {
  const ThemeEvent();
}

class ThemeToggleRequested extends ThemeEvent {
  const ThemeToggleRequested();
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.light) {
    on<ThemeToggleRequested>((event, emit) {
      if (state == ThemeMode.dark) {
        emit(ThemeMode.light);
      } else {
        emit(ThemeMode.dark);
      }
    });
  }
}
