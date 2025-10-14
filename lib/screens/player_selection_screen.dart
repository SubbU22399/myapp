import 'package:flutter/material.dart';
import 'package:myapp/models/player.dart';
import 'package:myapp/utils/constants.dart';
import 'game_screen.dart';

class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int _numPlayers = 2;
  final List<TextEditingController> _nameControllers = [];
  final List<Color> _playerColors = [Colors.blue, Colors.yellow, Colors.red, Colors.green];
  final List<String> _playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"];

  @override
  void initState() {
    super.initState();
    _updateNameControllers();
  }

  void _updateNameControllers() {
    _nameControllers.clear();
    for (int i = 0; i < _numPlayers; i++) {
      _nameControllers.add(TextEditingController(text: _playerNames[i]));
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Your Warriors',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                _buildPlayerNumberSelector(),
                const SizedBox(height: 20),
                _buildPlayerNameInputs(),
                const SizedBox(height: 30),
                _buildStartGameButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerNumberSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: DropdownButton<int>(
        value: _numPlayers,
        items: const [
          DropdownMenuItem(value: 2, child: Text('2 Warriors', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: 3, child: Text('3 Warriors', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: 4, child: Text('4 Warriors', style: TextStyle(color: Colors.white))),
        ],
        onChanged: (value) {
          setState(() {
            _numPlayers = value!;
            _updateNameControllers();
          });
        },
        dropdownColor: Colors.deepPurple,
        style: Theme.of(context).textTheme.bodyLarge,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_downward, color: Colors.yellow),
      ),
    );
  }

  Widget _buildPlayerNameInputs() {
    return Column(
      children: List.generate(_numPlayers, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
          child: TextField(
            controller: _nameControllers[index],
            decoration: InputDecoration(
              labelText: 'Player ${index + 1} Name',
              labelStyle: TextStyle(color: _playerColors[index]),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _playerColors[index], width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _playerColors[index].withOpacity(0.7), width: 1),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }),
    );
  }

  Widget _buildStartGameButton() {
    return ElevatedButton(
      onPressed: () {
        List<Player> players = [];
        for (int i = 0; i < _numPlayers; i++) {
          players.add(Player(
            name: _nameControllers[i].text,
            color: _playerColors[i],
            pieces: List.generate(4, (j) => outOfPlayPositions[i][j]),
            homeIndex: i,
          ));
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(players: players),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        elevation: 10,
        shadowColor: Colors.yellow.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text('Embark on the Quest'),
    );
  }
}
