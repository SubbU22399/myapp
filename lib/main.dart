import 'package:flutter/material.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.orange,
          surface: Colors.blueGrey,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          headlineSmall: TextStyle(
            color: Colors.yellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.yellow, blurRadius: 10)],
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // The initial screen of the application.
      home: const PlayerSelectionScreen(),
    );
  }
}
