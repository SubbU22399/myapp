import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

/// A screen that allows users to select players for the game.
///
/// This screen enables users to enter their names, choose a color, and add
/// themselves to the game. It enforces a minimum and maximum of 2
/// players. Once the desired number of players have joined, the game can be
/// started.
class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  // A list to hold the players that have been added to the game.
  final List<Player> _players = [];
  // A controller for the text field where users enter their name.
  final _nameController = TextEditingController();
  // A list of colors for the players.
  final List<Color> _playerColors = const [
    Colors.blue,
    Colors.red,
  ];

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the widget tree.
    _nameController.dispose();
    super.dispose();
  }

  /// Adds a new player to the game.
  ///
  /// This method is called when a user selects a color. It validates that the
  /// player name is not empty, the maximum number of players has not been
  /// reached, and the selected color is not already in use.
  void _addPlayer(Color color, int homeIndex) {
    final playerName = _nameController.text.trim();
    if (playerName.isNotEmpty &&
        _players.length < 2 &&
        !_players.any((p) => p.homeIndex == homeIndex)) {
      setState(() {
        _players.add(
          Player(
            name: playerName,
            homeIndex: homeIndex,
            color: color,
            // Initialize the player's pieces to be off the board.
            pieces: List.generate(4, (i) => outOfPlayPositions[homeIndex][i]),
          ),
        );
        // Clear the text field after adding a player.
        _nameController.clear();
      });
    }
  }

  /// Removes a player from the game.
  ///
  /// This method is called when a user taps the remove icon next to a player's
  /// name.
  void _removePlayer(int homeIndex) {
    setState(() {
      _players.removeWhere((p) => p.homeIndex == homeIndex);
    });
  }

  /// Starts the game.
  ///
  /// This method is called when the "Start Game" button is pressed. It
  /// navigates to the [GameScreen] and passes the list of players.
  void _startGame() {
    if (_players.length == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GameScreen(players: _players)),
      );
    }
  }

  /// Builds the color selection UI.
  ///
  /// This widget displays a grid of colors that users can choose from.
  Widget _buildPlayerSelection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_playerColors.length, (index) {
        final color = _playerColors[index];
        final isSelected = _players.any((p) => p.homeIndex == index);

        return GestureDetector(
          onTap: () {
            if (!isSelected) {
              _addPlayer(color, index);
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.5) : color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child:
                isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Players'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text field for player name input.
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Color selection section.
            const Text(
              'Choose your color:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPlayerSelection(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            // List of added players.
            Text(
              'Players (${_players.length}/2):',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: player.color),
                      title: Text(player.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removePlayer(player.homeIndex),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Button to start the game.
            ElevatedButton(
              // The button is disabled if there are not exactly 2 players.
              onPressed: _players.length == 2 ? _startGame : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
