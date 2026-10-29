import 'package:flutter/material.dart';

import 'core/theme/revix_palette.dart';
import 'features/vehicle_management/presentation/vehicle_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RevixApp());
}

class RevixApp extends StatelessWidget {
  const RevixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: RevixPalette.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: RevixPalette.primary,
          onPrimary: Colors.white,
          primaryContainer: RevixPalette.neutral,
          onPrimaryContainer: RevixPalette.ink,
          secondary: RevixPalette.accent,
          onSecondary: RevixPalette.ink,
          secondaryContainer: RevixPalette.neutral,
          onSecondaryContainer: RevixPalette.ink,
          tertiary: RevixPalette.neutral,
          onTertiary: RevixPalette.ink,
          surface: RevixPalette.background,
          onSurface: RevixPalette.ink,
          onSurfaceVariant: RevixPalette.ink,
          outline: RevixPalette.neutral,
          outlineVariant: RevixPalette.neutral,
          surfaceTint: RevixPalette.primary,
        );
    return MaterialApp(
      title: 'Revix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: colorScheme,
        scaffoldBackgroundColor: RevixPalette.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: RevixPalette.background,
          foregroundColor: RevixPalette.ink,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: RevixPalette.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: RevixPalette.neutral),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RevixPalette.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: RevixPalette.neutral),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: RevixPalette.neutral),
          ),
        ),
      ),
      home: const VehicleDashboardScreen(),
    );
  }
}
