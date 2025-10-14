import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CosmoQuestApp());
}

class CosmoQuestApp extends StatelessWidget {
  const CosmoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmo Quest',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PlayerSelectionScreen(),
    );
  }
}

// Player Selection Screen
class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int numPlayers = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmo Quest - Select Players'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
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
              ElevatedButton(
                onPressed: () {
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

// Game Screen
class GameScreen extends StatefulWidget {
  final int numPlayers;
  const GameScreen({super.key, required this.numPlayers});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const int gridSize = 7;
  static const List<List<int>> homes = [
    [6, 3], // Blue - Bird
    [3, 6], // Yellow - Snake
    [0, 3], // Red - Cat
    [3, 0], // Green - Frog
  ];
  static const List<List<int>> safeZones = [
    [1, 1],
    [1, 5],
    [5, 1],
    [5, 5],
    [2, 3],
    [3, 2],
    [4, 3],
    [3, 4],
  ];
  static const List<int> flag = [3, 3];

  static final List<List<List<int>>> spiralPaths = [
    // Blue (starts at [6, 3])
    [
      [6, 3],
      [6, 4],
      [6, 5],
      [6, 6],
      [5, 6],
      [4, 6],
      [3, 6],
      [2, 6],
      [1, 6],
      [0, 6],
      [0, 5],
      [0, 4],
      [0, 3],
      [0, 2],
      [0, 1],
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
      [4, 0],
      [5, 0],
      [6, 0],
      [6, 1],
      [6, 2],
      [5, 1],
      [4, 1],
      [3, 1],
      [2, 1],
      [1, 1],
      [1, 2],
      [1, 3],
      [1, 4],
      [2, 5],
      [3, 5],
      [4, 5],
      [5, 5],
      [5, 4],
      [5, 3],
      [5, 2],
      [4, 2],
      [3, 2],
      [2, 2],
      [2, 3],
      [2, 4],
      [3, 4],
      [4, 4],
      [4, 3],
      [3, 3],
    ],
    // Yellow (starts at [3, 6])
    [
      [3, 6],
      [2, 6],
      [1, 6],
      [0, 6],
      [0, 5],
      [0, 4],
      [0, 3],
      [0, 2],
      [0, 1],
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
      [4, 0],
      [5, 0],
      [6, 0],
      [6, 1],
      [6, 2],
      [6, 3],
      [6, 4],
      [6, 5],
      [6, 6],
      [5, 6],
      [4, 6],
      [5, 5],
      [4, 5],
      [3, 5],
      [2, 5],
      [1, 5],
      [1, 4],
      [1, 3],
      [1, 2],
      [1, 1],
      [2, 1],
      [3, 1],
      [4, 1],
      [5, 1],
      [5, 2],
      [5, 3],
      [5, 4],
      [4, 4],
      [4, 3],
      [4, 2],
      [3, 2],
      [2, 2],
      [2, 3],
      [2, 4],
      [3, 3],
    ],
    // Red (starts at [0, 3])
    [
      [0, 3],
      [0, 2],
      [0, 1],
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
      [4, 0],
      [5, 0],
      [6, 0],
      [6, 1],
      [6, 2],
      [6, 3],
      [6, 4],
      [6, 5],
      [6, 6],
      [5, 6],
      [4, 6],
      [3, 6],
      [2, 6],
      [1, 6],
      [0, 6],
      [0, 5],
      [0, 4],
      [1, 5],
      [2, 5],
      [3, 5],
      [4, 5],
      [5, 5],
      [5, 4],
      [5, 3],
      [5, 2],
      [5, 1],
      [4, 1],
      [3, 1],
      [2, 1],
      [1, 1],
      [1, 2],
      [1, 3],
      [1, 4],
      [2, 4],
      [3, 4],
      [4, 4],
      [4, 3],
      [4, 2],
      [3, 2],
      [2, 2],
      [2, 3],
      [3, 3],
    ],
    // Green (starts at [3, 0])
    [
      [3, 0],
      [4, 0],
      [5, 0],
      [6, 0],
      [6, 1],
      [6, 2],
      [6, 3],
      [6, 4],
      [6, 5],
      [6, 6],
      [5, 6],
      [4, 6],
      [3, 6],
      [2, 6],
      [1, 6],
      [0, 6],
      [0, 5],
      [0, 4],
      [0, 3],
      [0, 2],
      [0, 1],
      [0, 0],
      [1, 0],
      [2, 0],
      [1, 1],
      [2, 1],
      [3, 1],
      [4, 1],
      [5, 1],
      [5, 2],
      [5, 3],
      [5, 4],
      [5, 5],
      [4, 5],
      [3, 5],
      [2, 5],
      [1, 5],
      [1, 4],
      [1, 3],
      [1, 2],
      [2, 2],
      [2, 3],
      [2, 4],
      [3, 4],
      [4, 4],
      [4, 3],
      [4, 2],
      [3, 3],
    ],
  ];

  static const List<List<List<int>>> outOfPlayPositions = [
    // Blue (bottom)
    [
      [7, 0],
      [7, 1],
      [7, 2],
      [7, 3],
    ],
    // Yellow (right)
    [
      [0, 7],
      [1, 7],
      [2, 7],
      [3, 7],
    ],
    // Red (top)
    [
      [-1, 0],
      [-1, 1],
      [-1, 2],
      [-1, 3],
    ],
    // Green (left)
    [
      [0, -1],
      [1, -1],
      [2, -1],
      [3, -1],
    ],
  ];

  late List<Map<String, dynamic>> players;
  late AnimationController _pieceAnimationController;
  late Animation<double> _pieceAnimation;
  late AnimationController _diceAnimationController;
  late Animation<double> _diceAnimation;
  int diceRoll = 0;
  bool isRolling = false;
  int currentPlayer = 0;
  String status = "";
  bool hasUsedBoostThisTurn = false;

  @override
  void initState() {
    super.initState();
    _pieceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pieceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_pieceAnimationController)..addListener(() {
      if (mounted) setState(() {});
    });

    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _diceAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(_diceAnimationController)..addListener(() {
      if (mounted) setState(() {});
    });

    List<Map<String, dynamic>> allPlayers = [
      {
        'color': Colors.blue,
        'name': 'Blue',
        'pieces': [for (var i = 0; i < 4; i++) outOfPlayPositions[0][i]],
        'homeIndex': 0,
        'finished': 0,
        'cosmicBoosts': 3,
        'score': 0,
      },
      {
        'color': Colors.yellow,
        'name': 'Yellow',
        'pieces': [for (var i = 0; i < 4; i++) outOfPlayPositions[1][i]],
        'homeIndex': 1,
        'finished': 0,
        'cosmicBoosts': 3,
        'score': 0,
      },
      {
        'color': Colors.red,
        'name': 'Red',
        'pieces': [for (var i = 0; i < 4; i++) outOfPlayPositions[2][i]],
        'homeIndex': 2,
        'finished': 0,
        'cosmicBoosts': 3,
        'score': 0,
      },
      {
        'color': Colors.green,
        'name': 'Green',
        'pieces': [for (var i = 0; i < 4; i++) outOfPlayPositions[3][i]],
        'homeIndex': 3,
        'finished': 0,
        'cosmicBoosts': 3,
        'score': 0,
      },
    ];

    if (widget.numPlayers == 2) {
      players = [allPlayers[0], allPlayers[2]]; // Blue vs Red
    } else {
      players = allPlayers.take(widget.numPlayers).toList();
    }

    status = "${players[currentPlayer]['name']}'s Turn - Roll to Start";
  }

  @override
  void dispose() {
    _pieceAnimationController.dispose();
    _diceAnimationController.dispose();
    super.dispose();
  }

  bool isBlocked(int playerIndex, int pathIndex) {
    int count = 0;
    for (var player in players) {
      for (var piece in player['pieces']) {
        if (spiralPaths[playerIndex][pathIndex][0] == piece[0] &&
            spiralPaths[playerIndex][pathIndex][1] == piece[1]) {
          count++;
        }
      }
    }
    return count >= 2;
  }

  bool canMovePiece() {
    var player = players[currentPlayer];
    var path = spiralPaths[player['homeIndex']];
    for (var piece in player['pieces']) {
      int currentIndex = path.indexWhere(
        (p) => p[0] == piece[0] && p[1] == piece[1],
      );
      if (piece[0] < 0 ||
          piece[0] >= gridSize ||
          piece[1] < 0 ||
          piece[1] >= gridSize) {
        if (diceRoll == 6) return true; // Can bring piece in
      } else if (currentIndex != -1 && currentIndex < path.length - 1) {
        int newIndex = currentIndex + diceRoll;
        if (newIndex >= path.length) newIndex = path.length - 1;
        if (newIndex == path.length - 1 ||
            !isBlocked(player['homeIndex'], newIndex)) {
          return true;
        }
      }
    }
    return false;
  }

  void rollDice() {
    if (isRolling) return;
    setState(() {
      isRolling = true;
      _diceAnimationController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            diceRoll = Random().nextInt(6) + 1;
            isRolling = false;
            hasUsedBoostThisTurn = false;
            status =
                "${players[currentPlayer]['name']}'s Turn - Rolled a $diceRoll";
            print("Dice rolled: $diceRoll");
            if (!canMovePiece()) {
              status += " - No moves possible, passing turn!";
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    currentPlayer = (currentPlayer + 1) % players.length;
                    status =
                        "${players[currentPlayer]['name']}'s Turn - Roll to Start";
                    diceRoll = 0;
                  });
                }
              });
            } else {
              status += " - Tap a piece to move";
            }
          });
        }
      });
    });
  }

  void useCosmicBoost(String type) {
    if (diceRoll == 0 ||
        players[currentPlayer]['cosmicBoosts'] <= 0 ||
        hasUsedBoostThisTurn ||
        isRolling) {
      return;
    }
    setState(() {
      players[currentPlayer]['cosmicBoosts']--;
      hasUsedBoostThisTurn = true;
      print("Cosmic Boost used: $type");
      if (type == 'reroll') {
        isRolling = true;
        _diceAnimationController.forward(from: 0).then((_) {
          if (mounted) {
            setState(() {
              diceRoll = Random().nextInt(6) + 1;
              isRolling = false;
              status =
                  "${players[currentPlayer]['name']}'s Turn - Rerolled a $diceRoll - Tap a piece to move";
            });
          }
        });
      } else if (type == 'shortcut') {
        status =
            "${players[currentPlayer]['name']}'s Turn - Use shortcut by tapping a piece";
      } else if (type == 'double') {
        diceRoll *= 2;
        status =
            "${players[currentPlayer]['name']}'s Turn - Doubled to $diceRoll - Tap a piece to move";
      }
    });
  }

  void movePiece(int playerIndex, int pieceIndex, {bool isShortcut = false}) {
    if (diceRoll == 0 ||
        playerIndex != currentPlayer ||
        isRolling ||
        !mounted) {
      print(
        "Move blocked: diceRoll=$diceRoll, playerIndex=$playerIndex, currentPlayer=$currentPlayer, isRolling=$isRolling, mounted=$mounted",
      );
      return;
    }
    setState(() {
      var player = players[playerIndex];
      var piece = player['pieces'][pieceIndex];
      var path = spiralPaths[player['homeIndex']];
      int currentIndex = path.indexWhere(
        (p) => p[0] == piece[0] && p[1] == piece[1],
      );
      print(
        "Moving piece for ${player['name']}, pieceIndex=$pieceIndex, currentPos=$piece, currentIndex=$currentIndex",
      );

      _pieceAnimationController.forward(from: 0);

      if (piece[0] < 0 ||
          piece[0] >= gridSize ||
          piece[1] < 0 ||
          piece[1] >= gridSize) {
        if (diceRoll == 6) {
          player['pieces'][pieceIndex] = path[0];
          status =
              "${player['name']} moved a piece onto the board at ${path[0]}!";
          print("Piece entered board: ${path[0]}");
        } else {
          status = "${player['name']} needs a 6 to bring a piece into play!";
          print("Need a 6 to enter, rolled: $diceRoll");
          diceRoll = 0;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status =
                    "${players[currentPlayer]['name']}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }
      } else if (currentIndex != -1 && currentIndex < path.length - 1) {
        int newIndex = isShortcut ? currentIndex + 1 : currentIndex + diceRoll;
        print(
          "Calculated newIndex=$newIndex, pathLength=${path.length}, isShortcut=$isShortcut",
        );
        if (newIndex > path.length - 1) {
          status = "${player['name']} overshot the flag - exact roll needed!";
          diceRoll = 0;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status =
                    "${players[currentPlayer]['name']}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }
        if (newIndex == path.length - 1 &&
            currentIndex + diceRoll != path.length - 1 &&
            !isShortcut) {
          status = "${player['name']} needs an exact roll to reach the flag!";
          diceRoll = 0;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status =
                    "${players[currentPlayer]['name']}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }
        if (isBlocked(player['homeIndex'], newIndex)) {
          status = "${player['name']} blocked by another player's pieces!";
          diceRoll = 0;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status =
                    "${players[currentPlayer]['name']}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }

        player['pieces'][pieceIndex] = path[newIndex];
        print("Piece moved to: ${path[newIndex]}");

        if (!safeZones.any(
          (s) => s[0] == path[newIndex][0] && s[1] == path[newIndex][1],
        )) {
          for (var opponent in players) {
            if (opponent != player) {
              for (int i = 0; i < opponent['pieces'].length; i++) {
                if (opponent['pieces'][i][0] == path[newIndex][0] &&
                    opponent['pieces'][i][1] == path[newIndex][1]) {
                  opponent['pieces'][i] =
                      outOfPlayPositions[opponent['homeIndex']][i];
                  status =
                      "${player['name']} captured ${opponent['name']}'s piece!";
                  print(
                    "Captured ${opponent['name']}'s piece at ${path[newIndex]}",
                  );
                }
              }
            }
          }
        }

        status =
            "${player['name']} moved to (${player['pieces'][pieceIndex][0]}, ${player['pieces'][pieceIndex][1]})";
        if (player['pieces'][pieceIndex] == flag) {
          status = "${player['name']}'s piece reached the Cosmic Flag! 🎉";
          player['finished']++;
          player['score'] += 10;
          print("Flag reached, finished: ${player['finished']}");
          if (player['finished'] == 4) {
            status = "${player['name']} Wins! 🌟 Confetti Explosion! 🌟";
            diceRoll = 0;
            return;
          }
        }
      }

      diceRoll = 0;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            currentPlayer = (currentPlayer + 1) % players.length;
            status = "${players[currentPlayer]['name']}'s Turn - Roll to Start";
          });
        }
      });
    });
  }

  void resetGame() {
    if (isRolling) return;
    setState(() {
      currentPlayer = 0;
      diceRoll = 0;
      isRolling = false;
      hasUsedBoostThisTurn = false;
      status = "${players[currentPlayer]['name']}'s Turn - Roll to Start";
      for (var player in players) {
        player['pieces'] = [
          for (var i = 0; i < 4; i++)
            outOfPlayPositions[player['homeIndex']][i],
        ];
        player['finished'] = 0;
        player['cosmicBoosts'] = 3;
        player['score'] = 0;
      }
    });
  }

  Widget buildAnimalPiece(int homeIndex) {
    switch (homeIndex) {
      case 0: // Blue - Bird
        return AnimatedBuilder(
          animation: _pieceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -sin(_pieceAnimation.value * 2 * pi) * 15),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐦', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      case 1: // Yellow - Snake
        return AnimatedBuilder(
          animation: _pieceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(sin(_pieceAnimation.value * 2 * pi) * 10, 0),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.yellow, Colors.amber],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐍', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      case 2: // Red - Cat
        return AnimatedBuilder(
          animation: _pieceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + sin(_pieceAnimation.value * pi) * 0.4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐱', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      case 3: // Green - Frog
        return AnimatedBuilder(
          animation: _pieceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -sin(_pieceAnimation.value * pi) * 20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.green, Colors.lime]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐸', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      default:
        return Container();
    }
  }

  Widget buildDice() {
    final rollValue = isRolling ? (Random().nextInt(6) + 1) : diceRoll;
    return AnimatedBuilder(
      animation: _diceAnimation,
      builder: (context, child) {
        return Transform(
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.01)
                ..rotateX(_diceAnimation.value * pi)
                ..rotateY(_diceAnimation.value * pi / 2),
          alignment: Alignment.center,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade300],
              ),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rollValue.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildOutOfPlayArea(int homeIndex, Alignment alignment) {
    int playerIndex = players.indexWhere((p) => p['homeIndex'] == homeIndex);
    if (playerIndex == -1) return const SizedBox.shrink();

    return Container(
      alignment: alignment,
      child:
          homeIndex == 0 || homeIndex == 2
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 4; i++)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child:
                          players[playerIndex]['pieces'].any(
                                (p) =>
                                    p[0] ==
                                        outOfPlayPositions[homeIndex][i][0] &&
                                    p[1] == outOfPlayPositions[homeIndex][i][1],
                              )
                              ? GestureDetector(
                                onTap: () {
                                  if (!isRolling &&
                                      diceRoll > 0 &&
                                      playerIndex == currentPlayer) {
                                    print(
                                      "Tapped out-of-play piece at ${outOfPlayPositions[homeIndex][i]} for ${players[playerIndex]['name']}",
                                    );
                                    movePiece(
                                      playerIndex,
                                      players[playerIndex]['pieces'].indexWhere(
                                        (p) =>
                                            p[0] ==
                                                outOfPlayPositions[homeIndex][i][0] &&
                                            p[1] ==
                                                outOfPlayPositions[homeIndex][i][1],
                                      ),
                                    );
                                  } else {
                                    print(
                                      "Tap ignored: isRolling=$isRolling, diceRoll=$diceRoll, playerIndex=$playerIndex, currentPlayer=$currentPlayer",
                                    );
                                  }
                                },
                                child: buildAnimalPiece(homeIndex),
                              )
                              : null,
                    ),
                ],
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 4; i++)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child:
                          players[playerIndex]['pieces'].any(
                                (p) =>
                                    p[0] ==
                                        outOfPlayPositions[homeIndex][i][0] &&
                                    p[1] == outOfPlayPositions[homeIndex][i][1],
                              )
                              ? GestureDetector(
                                onTap: () {
                                  if (!isRolling &&
                                      diceRoll > 0 &&
                                      playerIndex == currentPlayer) {
                                    print(
                                      "Tapped out-of-play piece at ${outOfPlayPositions[homeIndex][i]} for ${players[playerIndex]['name']}",
                                    );
                                    movePiece(
                                      playerIndex,
                                      players[playerIndex]['pieces'].indexWhere(
                                        (p) =>
                                            p[0] ==
                                                outOfPlayPositions[homeIndex][i][0] &&
                                            p[1] ==
                                                outOfPlayPositions[homeIndex][i][1],
                                      ),
                                    );
                                  } else {
                                    print(
                                      "Tap ignored: isRolling=$isRolling, diceRoll=$diceRoll, playerIndex=$playerIndex, currentPlayer=$currentPlayer",
                                    );
                                  }
                                },
                                child: buildAnimalPiece(homeIndex),
                              )
                              : null,
                    ),
                ],
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmo Quest'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(seconds: 5),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    center: Alignment.center,
                  ),
                ),
                child: CustomPaint(painter: StarryBackgroundPainter()),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildOutOfPlayArea(3, Alignment.centerLeft), // Green
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          buildOutOfPlayArea(2, Alignment.center), // Red
                          SizedBox(
                            width: 350,
                            height: 350,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridSize,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: gridSize * gridSize,
                              itemBuilder: (context, index) {
                                int x = index ~/ gridSize;
                                int y = index % gridSize;
                                bool isHome = homes.any(
                                  (h) => h[0] == x && h[1] == y,
                                );
                                bool isSafe = safeZones.any(
                                  (s) => s[0] == x && s[1] == y,
                                );
                                bool isFlag = x == flag[0] && y == flag[1];

                                int? playerIndex;
                                int? pieceIndex;
                                for (int p = 0; p < players.length; p++) {
                                  int idx = players[p]['pieces'].indexWhere(
                                    (pos) => pos[0] == x && pos[1] == y,
                                  );
                                  if (idx != -1) {
                                    playerIndex = p;
                                    pieceIndex = idx;
                                    break;
                                  }
                                }

                                return GestureDetector(
                                  onTap: () {
                                    if (!isRolling &&
                                        diceRoll > 0 &&
                                        playerIndex != null &&
                                        pieceIndex != null &&
                                        playerIndex == currentPlayer) {
                                      print(
                                        "Tapped board piece at [$x, $y] for ${players[playerIndex]['name']}",
                                      );
                                      movePiece(
                                        playerIndex,
                                        pieceIndex,
                                        isShortcut:
                                            hasUsedBoostThisTurn &&
                                            status.contains('shortcut'),
                                      );
                                    } else {
                                      print(
                                        "Board tap ignored: isRolling=$isRolling, diceRoll=$diceRoll, playerIndex=$playerIndex, currentPlayer=$currentPlayer",
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color:
                                          isHome
                                              ? Colors.blue.withOpacity(0.8)
                                              : isSafe
                                              ? Colors.blue.withOpacity(0.5)
                                              : isFlag
                                              ? Colors.purple.withOpacity(0.9)
                                              : Colors.yellow.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow:
                                          isFlag || isSafe
                                              ? [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Center(
                                      child:
                                          playerIndex != null
                                              ? buildAnimalPiece(
                                                players[playerIndex]['homeIndex'],
                                              )
                                              : Text(
                                                isSafe
                                                    ? '✨'
                                                    : isFlag
                                                    ? '🌍'
                                                    : '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                              ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          buildOutOfPlayArea(0, Alignment.center), // Blue
                        ],
                      ),
                      const SizedBox(width: 20),
                      buildOutOfPlayArea(1, Alignment.centerRight), // Yellow
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed:
                            diceRoll == 0 && !isRolling ? rollDice : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text(
                          'Roll Dice',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      buildDice(),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            diceRoll != 0 &&
                                    players[currentPlayer]['cosmicBoosts'] >
                                        0 &&
                                    !hasUsedBoostThisTurn &&
                                    !isRolling
                                ? () => useCosmicBoost('reroll')
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Reroll',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            diceRoll != 0 &&
                                    players[currentPlayer]['cosmicBoosts'] >
                                        0 &&
                                    !hasUsedBoostThisTurn &&
                                    !isRolling
                                ? () => useCosmicBoost('shortcut')
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Shortcut',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            diceRoll != 0 &&
                                    players[currentPlayer]['cosmicBoosts'] >
                                        0 &&
                                    !hasUsedBoostThisTurn &&
                                    !isRolling
                                ? () => useCosmicBoost('double')
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Double',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: !isRolling ? resetGame : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cosmic Boosts: ',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.yellow, blurRadius: 5),
                          ],
                        ),
                      ),
                      for (
                        int i = 0;
                        i < players[currentPlayer]['cosmicBoosts'];
                        i++
                      )
                        const Icon(Icons.star, color: Colors.yellow, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: players[currentPlayer]['color'].withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${players[currentPlayer]['name']}'s Turn (Score: ${players[currentPlayer]['score']})",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.yellow, blurRadius: 5)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Starry Background
class StarryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    final random = Random();
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
