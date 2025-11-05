import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF6366F1);
  static const Color _lightSecondary = Color(0xFF8B5CF6);
  static const Color _lightBackground = Color(0xFFF8FAFC);
  static const Color _lightSurface = Colors.white;
  static const Color _lightError = Color(0xFFEF4444);

  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF818CF8);
  static const Color _darkSecondary = Color(0xFFA78BFA);
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkError = Color(0xFFF87171);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      error: _lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E293B),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: _lightBackground,
      foregroundColor: Color(0xFF1E293B),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _lightSurface,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white; // 켜져있을 때 하얀색 thumb
        }
        return Colors.grey[600]; // 꺼져있을 때 회색
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightPrimary; // 켜져있을 때 Primary 색상 트랙
        }
        return Colors.grey[400]; // 꺼져있을 때 밝은 회색
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return Colors.grey[400]!; // 꺼져있을 때 테두리
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightError, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF475569)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      error: _darkError,
      onPrimary: Color(0xFF0F172A),
      onSecondary: Color(0xFF0F172A),
      onSurface: Color(0xFFF1F5F9),
      onError: Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: _darkBackground,
      foregroundColor: Color(0xFFF1F5F9),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _darkSurface,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: _darkPrimary,
      foregroundColor: Color(0xFF0F172A),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white; // 켜져있을 때 하얀색 thumb
        }
        return Colors.grey[600]; // 꺼져있을 때 회색
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkPrimary; // 켜져있을 때 Primary 색상 트랙
        }
        return Colors.grey[700]; // 꺼져있을 때 어두운 회색
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return Colors.grey[600]!; // 꺼져있을 때 테두리
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkError, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF1F5F9),
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF1F5F9),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF1F5F9),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF1F5F9),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFCBD5E1)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
    ),
  );
}
