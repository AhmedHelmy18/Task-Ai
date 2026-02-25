import 'package:flutter/material.dart';

var appDarkTheme = ColorScheme.dark(
  brightness: Brightness.dark,
  primary: const Color(0xff0F33E6),
  onPrimary: Colors.white,
  secondary: const Color(0xff3B82F6),
  onSecondary: const Color(0xff64748B),
  tertiary: const Color(0xff8B5CF6),
  error: const Color(0xffEF4444),
  surface: const Color(0xff0F172A),
  onSurface: Colors.white,
  primaryContainer: const Color(0xff101322),
  surfaceContainer: const Color(0xff334155),
  onSecondaryContainer: const Color(0xff10B981),
  onTertiaryContainer: const Color(0xffF59E0B),
).copyWith(surface: const Color(0xff0F172A));

var appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: appDarkTheme,
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xff0F172A),
    dayPeriodColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff0F33E6);
      }
      return Colors.transparent;
    }),
    dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return const Color(0xff64748B);
    }),
    dayPeriodBorderSide: const BorderSide(color: Color(0xff334155)),
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    dialBackgroundColor: const Color(0xff1E293B),
    dialHandColor: const Color(0xff0F33E6),
    dialTextColor: Colors.white,
    entryModeIconColor: Colors.white,
  ),
);
