import 'package:flutter/material.dart';
import 'game_screen.dart';

// The screen where players can select the number of players for the game.
class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  // The number of players selected.
  int numPlayers = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmo Quest - Select Players'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        // Creates a gradient background.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Number of Players:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.yellow, blurRadius: 10)],
                ),
              ),
              // A dropdown menu to select the number of players.
              DropdownButton<int>(
                value: numPlayers,
                items: const [
                  DropdownMenuItem(value: 2, child: Text('2 Players')),
                  DropdownMenuItem(value: 3, child: Text('3 Players')),
                  DropdownMenuItem(value: 4, child: Text('4 Players')),
                ],
                onChanged: (value) {
                  setState(() {
                    numPlayers = value!;
                  });
                },
                dropdownColor: Colors.deepPurple,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              // A button to start the game.
              ElevatedButton(
                onPressed: () {
                  // Navigates to the game screen with the selected number of players.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(numPlayers: numPlayers),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
