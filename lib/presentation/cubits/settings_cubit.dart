import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    final languageCode = prefs.getString('languageCode') ?? 'en';
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final notificationMinutesBefore =
        prefs.getInt('notificationMinutesBefore') ?? 15;

    emit(
      SettingsState(
        themeMode: ThemeMode.values[themeModeIndex],
        languageCode: languageCode,
        notificationsEnabled: notificationsEnabled,
        notificationMinutesBefore: notificationMinutesBefore,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setNotificationMinutesBefore(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationMinutesBefore', minutes);
    emit(state.copyWith(notificationMinutesBefore: minutes));
  }
}
