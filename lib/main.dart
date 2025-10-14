import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/player_selection_screen.dart';

// Main entry point of the Flutter application.
void main() {
  runApp(const CosmoQuestApp());
}

// The root widget of the Cosmo Quest application.
class CosmoQuestApp extends StatelessWidget {
  const CosmoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Sets the application title.
      title: 'Cosmo Quest',
      // Defines the overall theme for the application.
      theme: FlexThemeData.dark(
        scheme: FlexScheme.deepPurple,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.orbitron().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.deepPurple,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.orbitron().fontFamily,
      ),
      themeMode: ThemeMode.dark,
      // The initial screen of the application.
      home: const PlayerSelectionScreen(),
    );
  }
}
