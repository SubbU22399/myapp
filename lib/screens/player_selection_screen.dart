import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

/// A screen that allows users to select players for the game.
///
/// This screen enables users to enter their names, choose a color, and add
/// themselves to the game. It's designed for a two-player game. Once both
/// players have joined, the game can be started.
class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  // Controllers for the player name text fields.
  final _player1NameController = TextEditingController();
  final _player2NameController = TextEditingController();

  // The selected players.
  Player? _player1;
  Player? _player2;

  // The list of available colors for the players.
  final List<Color> _playerColors = const [
    Colors.blue,
    Colors.red,
  ];

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the widget tree.
    _player1NameController.dispose();
    _player2NameController.dispose();
    super.dispose();
  }

  /// Adds or updates a player.
  void _updatePlayer(int playerIndex, String name) {
    setState(() {
      if (playerIndex == 0) {
        _player1 = Player(
          name: name,
          homeIndex: 0,
          color: _playerColors[0],
          pieces: List.generate(4, (i) => outOfPlayPositions[0][i]),
        );
      } else {
        _player2 = Player(
          name: name,
          homeIndex: 1,
          color: _playerColors[1],
          pieces: List.generate(4, (i) => outOfPlayPositions[1][i]),
        );
      }
    });
  }

  /// Starts the game.
  ///
  /// This method is called when the "Start Game" button is pressed. It
  /// navigates to the [GameScreen] and passes the list of players.
  void _startGame() {
    // Update players with the latest names from controllers before starting.
    _updatePlayer(0, _player1NameController.text.trim());
    _updatePlayer(1, _player2NameController.text.trim());

    if (_player1 != null && _player2 != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(players: [_player1!, _player2!]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Cosmic Duel'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player 1 input.
            _buildPlayerInput(
              controller: _player1NameController,
              playerColor: _playerColors[0],
              label: 'Player 1 (Blue)',
            ),
            const SizedBox(height: 20),
            // Player 2 input.
            _buildPlayerInput(
              controller: _player2NameController,
              playerColor: _playerColors[1],
              label: 'Player 2 (Red)',
            ),
            const Spacer(),
            // Button to start the game.
            ElevatedButton(
              onPressed: () {
                if (_player1NameController.text.trim().isNotEmpty &&
                    _player2NameController.text.trim().isNotEmpty) {
                  _startGame();
                } else {
                  // Optional: Show a snackbar or alert to inform the user to fill in names.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter names for both players.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Start Cosmic Battle'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds a player input section with a text field and color indicator.
  Widget _buildPlayerInput({
    required TextEditingController controller,
    required Color playerColor,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: playerColor,
            radius: 12,
          ),
        ),
      ),
      onChanged: (name) {
        // You could update the player object in real time if you want,
        // but updating on "Start Game" press is also fine.
      },
    );
  }
}