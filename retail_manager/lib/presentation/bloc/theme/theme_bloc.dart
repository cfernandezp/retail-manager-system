import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  
  @override
  List<Object> get props => [];
}

class ToggleTheme extends ThemeEvent {}

class LoadTheme extends ThemeEvent {}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();
  
  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;
  
  const ThemeLoaded({
    required this.themeMode,
    required this.isDarkMode,
  });
  
  @override
  List<Object> get props => [themeMode, isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  late Box _settingsBox;

  ThemeBloc() : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      add(LoadTheme());
    } catch (e) {
      // Fallback to light theme if Hive fails
      emit(const ThemeLoaded(
        themeMode: ThemeMode.light,
        isDarkMode: false,
      ));
    }
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    try {
      final isDark = _settingsBox.get(_themeKey, defaultValue: false) as bool;
      emit(ThemeLoaded(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        isDarkMode: isDark,
      ));
    } catch (e) {
      // Fallback to light theme
      emit(const ThemeLoaded(
        themeMode: ThemeMode.light,
        isDarkMode: false,
      ));
    }
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      final newIsDark = !currentState.isDarkMode;
      
      try {
        await _settingsBox.put(_themeKey, newIsDark);
        emit(ThemeLoaded(
          themeMode: newIsDark ? ThemeMode.dark : ThemeMode.light,
          isDarkMode: newIsDark,
        ));
      } catch (e) {
        // If saving fails, still emit the new state
        emit(ThemeLoaded(
          themeMode: newIsDark ? ThemeMode.dark : ThemeMode.light,
          isDarkMode: newIsDark,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _settingsBox.close();
    return super.close();
  }
}