import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/storage_keys.dart';
import '../services/storage_service.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit(this._storageService)
      : super(_parseThemeMode(_storageService.getString(StorageKeys.appThemeMode)));

  final StorageService _storageService;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) {
      return;
    }

    emit(mode);
    await _storageService.setString(StorageKeys.appThemeMode, mode.name);
  }

  static ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }
}
