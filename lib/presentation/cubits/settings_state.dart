import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'settings_state.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default('en') String languageCode,
    @Default(true) bool notificationsEnabled,
    @Default(15) int notificationMinutesBefore,
  }) = _SettingsState;
}
