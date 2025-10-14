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
        title: Text('Cosmo Quest', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        // Creates a gradient background.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Your Warriors',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              // A dropdown menu to select the number of players.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: DropdownButton<int>(
                  value: numPlayers,
                  items: const [
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2 Warriors', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('3 Warriors', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('4 Warriors', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      numPlayers = value!;
                    });
                  },
                  dropdownColor: Colors.deepPurple,
                  style: Theme.of(context).textTheme.bodyLarge,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_downward, color: Colors.yellow),
                ),
              ),
              const SizedBox(height: 40),
              // A button to start the game.
              ElevatedButton(
                onPressed: () {
                  // Navigates to the game screen with the selected number of players.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(numPlayers: numPlayers),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  elevation: 10,
                  shadowColor: Colors.yellow.withOpacity(0.5),
                ),
                child: const Text('Embark on the Quest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
