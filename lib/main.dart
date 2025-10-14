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
      theme: ThemeData(primarySwatch: Colors.blue),
      // The initial screen of the application.
      home: const PlayerSelectionScreen(),
    );
  }
}
