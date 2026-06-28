import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_storage_keys.dart';
import '../../core/services/storage_service.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit(this._storageService)
      : super(_parseThemeMode(_storageService.getString(AppStorageKeys.appThemeMode)));

  final StorageService _storageService;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) {
      return;
    }

    emit(mode);
    await _storageService.setString(AppStorageKeys.appThemeMode, mode.name);
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
