import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import '../widgets/animal_piece.dart';
import '../widgets/dice.dart';
import '../widgets/game_board.dart';

// The main screen of the game, where the game is played.
class GameScreen extends StatefulWidget {
  // The number of players in the game.
  final int numPlayers;
  const GameScreen({super.key, required this.numPlayers});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // A list of players in the game.
  late List<Player> players;
  // Animation controllers and animations for the pieces, dice, and indicators.
  late AnimationController _pieceAnimationController;
  late Animation<double> _pieceAnimation;
  late AnimationController _diceAnimationController;
  late Animation<double> _diceAnimation;
  late AnimationController _indicatorAnimationController;
  late Animation<double> _indicatorAnimation;
  // The result of the dice roll.
  int diceRoll = 0;
  // Whether the dice is currently rolling.
  bool isRolling = false;
  // The index of the current player.
  int currentPlayer = 0;
  // The current status message.
  String status = "";
  // Whether the current player has used a cosmic boost in this turn.
  bool hasUsedBoostThisTurn = false;
  // Whether the game is over.
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    // Initializes the animation controllers and animations.
    _pieceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pieceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_pieceAnimationController)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    final customCurve = Curves.elasticOut;
    _diceAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _diceAnimationController, curve: customCurve))
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _indicatorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
    _indicatorAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _indicatorAnimationController, curve: Curves.easeInOut),
    );

    // Initializes the players.
    List<Player> allPlayers = [
      Player(
        color: Colors.blue,
        name: 'Blue',
        pieces: [for (var i = 0; i < 4; i++) outOfPlayPositions[0][i]],
        homeIndex: 0,
      ),
      Player(
        color: Colors.yellow,
        name: 'Yellow',
        pieces: [for (var i = 0; i < 4; i++) outOfPlayPositions[1][i]],
        homeIndex: 1,
      ),
      Player(
        color: Colors.red,
        name: 'Red',
        pieces: [for (var i = 0; i < 4; i++) outOfPlayPositions[2][i]],
        homeIndex: 2,
      ),
      Player(
        color: Colors.green,
        name: 'Green',
        pieces: [for (var i = 0; i < 4; i++) outOfPlayPositions[3][i]],
        homeIndex: 3,
      ),
    ];

    // Selects the players based on the number of players selected.
    if (widget.numPlayers == 2) {
      players = [allPlayers[0], allPlayers[2]]; // Blue vs Red
    } else {
      players = allPlayers.take(widget.numPlayers).toList();
    }

    // Sets the initial status message.
    status = "${players[currentPlayer].name}'s Turn - Roll to Start";
  }

  @override
  void dispose() {
    // Disposes the animation controllers.
    _pieceAnimationController.dispose();
    _diceAnimationController.dispose();
    _indicatorAnimationController.dispose();
    super.dispose();
  }

  // Checks if a path is blocked by another player's pieces.
  bool isBlocked(int playerIndex, int pathIndex) {
    int count = 0;
    for (var player in players) {
      for (var piece in player.pieces) {
        if (spiralPaths[playerIndex][pathIndex][0] == piece[0] &&
            spiralPaths[playerIndex][pathIndex][1] == piece[1]) {
          count++;
        }
      }
    }
    return count >= 2;
  }

  // Checks if the current player can move a piece.
  bool canMovePiece() {
    var player = players[currentPlayer];
    var path = spiralPaths[player.homeIndex];
    for (var piece in player.pieces) {
      int currentIndex = path.indexWhere(
        (p) => p[0] == piece[0] && p[1] == piece[1],
      );
      // If the piece is out of play, it can be moved if the dice roll is 6.
      if (piece[0] < 0 || piece[0] >= gridSize || piece[1] < 0 || piece[1] >= gridSize) {
        if (diceRoll == 6) return true; // Can bring piece in
      } else if (currentIndex != -1 && currentIndex < path.length - 1) {
        // If the piece is on the board, it can be moved if the new position is not blocked.
        int newIndex = currentIndex + diceRoll;
        if (newIndex >= path.length) newIndex = path.length - 1;
        if (newIndex == path.length - 1 || !isBlocked(player.homeIndex, newIndex)) {
          return true;
        }
      }
    }
    return false;
  }

  // Rolls the dice.
  void rollDice() {
    if (isRolling || _isGameOver) return;
    setState(() {
      isRolling = true;
      // Starts the dice roll animation.
      _diceAnimationController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            diceRoll = Random().nextInt(6) + 1;
            isRolling = false;
            hasUsedBoostThisTurn = false;
            status = "${players[currentPlayer].name}'s Turn - Rolled a $diceRoll";
            // If there are no possible moves, the turn is passed to the next player.
            if (!canMovePiece()) {
              status += " - No moves possible, passing turn!";
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    currentPlayer = (currentPlayer + 1) % players.length;
                    status = "${players[currentPlayer].name}'s Turn - Roll to Start";
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

  // Uses a cosmic boost.
  void useCosmicBoost(String type) {
    if (diceRoll == 0 ||
        players[currentPlayer].cosmicBoosts <= 0 ||
        hasUsedBoostThisTurn ||
        isRolling) {
      return;
    }
    setState(() {
      players[currentPlayer].cosmicBoosts--;
      hasUsedBoostThisTurn = true;
      if (type == 'reroll') {
        // Rerolls the dice.
        isRolling = true;
        _diceAnimationController.forward(from: 0).then((_) {
          if (mounted) {
            setState(() {
              diceRoll = Random().nextInt(6) + 1;
              isRolling = false;
              status =
                  "${players[currentPlayer].name}'s Turn - Rerolled a $diceRoll - Tap a piece to move";
            });
          }
        });
      } else if (type == 'shortcut') {
        // Uses a shortcut.
        status = "${players[currentPlayer].name}'s Turn - Use shortcut by tapping a piece";
      } else if (type == 'double') {
        // Doubles the dice roll.
        diceRoll *= 2;
        status = "${players[currentPlayer].name}'s Turn - Doubled to $diceRoll - Tap a piece to move";
      }
    });
  }

  // Moves a piece.
  void movePiece(int playerIndex, int pieceIndex, {bool isShortcut = false}) {
    if (diceRoll == 0 ||
        playerIndex != currentPlayer ||
        isRolling ||
        !mounted ||
        _isGameOver) {
      return;
    }
    setState(() {
      var player = players[playerIndex];
      var piece = player.pieces[pieceIndex];
      var path = spiralPaths[player.homeIndex];
      int currentIndex = path.indexWhere(
        (p) => p[0] == piece[0] && p[1] == piece[1],
      );

      // Starts the piece move animation.
      _pieceAnimationController.forward(from: 0);

      // If the piece is out of play, it can be moved if the dice roll is 6.
      if (piece[0] < 0 || piece[0] >= gridSize || piece[1] < 0 || piece[1] >= gridSize) {
        if (diceRoll == 6) {
          player.pieces[pieceIndex] = path[0];
          status = "${player.name} moved a piece onto the board at ${path[0]}!";
        } else {
          status = "${player.name} needs a 6 to bring a piece into play!";
          diceRoll = 0;
          // Passes the turn to the next player.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status = "${players[currentPlayer].name}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }
      } else if (currentIndex != -1 && currentIndex < path.length - 1) {
        // If the piece is on the board, it is moved to the new position.
        int newIndex = isShortcut ? currentIndex + 1 : currentIndex + diceRoll;
        if (newIndex > path.length - 1) {
          status = "${player.name} overshot the flag - exact roll needed!";
          diceRoll = 0;
          // Passes the turn to the next player.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status = "${players[currentPlayer].name}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }
        if (newIndex == path.length - 1 &&
            currentIndex + diceRoll != path.length - 1 &&
            !isShortcut) {
          status = "${player.name} needs an exact roll to reach the flag!";
          diceRoll = 0;
          // Passes the turn to the next player.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status = "${players[currentPlayer].name}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }
        if (isBlocked(player.homeIndex, newIndex)) {
          status = "${player.name} blocked by another player's pieces!";
          diceRoll = 0;
          // Passes the turn to the next player.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                currentPlayer = (currentPlayer + 1) % players.length;
                status = "${players[currentPlayer].name}'s Turn - Roll to Start";
              });
            }
          });
          return;
        }

        player.pieces[pieceIndex] = path[newIndex];

        // If the piece lands on an opponent's piece, the opponent's piece is sent back to its home.
        if (!safeZones.any((s) => s[0] == path[newIndex][0] && s[1] == path[newIndex][1])) {
          for (var opponent in players) {
            if (opponent != player) {
              for (int i = 0; i < opponent.pieces.length; i++) {
                if (opponent.pieces[i][0] == path[newIndex][0] &&
                    opponent.pieces[i][1] == path[newIndex][1]) {
                  opponent.pieces[i] = outOfPlayPositions[opponent.homeIndex][i];
                  status = "${player.name} captured ${opponent.name}'s piece!";
                }
              }
            }
          }
        }

        status = "${player.name} moved to (${player.pieces[pieceIndex][0]}, ${player.pieces[pieceIndex][1]})";
        // If the piece reaches the flag, the player's score is increased.
        if (player.pieces[pieceIndex] == flag) {
          status = "${player.name}'s piece reached the Cosmic Flag! 🎉";
          player.finished++;
          player.score += 10;
          // If all of the player's pieces have reached the flag, the game is over.
          if (player.finished == 4) {
            status = "${player.name} Wins! 🌟 Confetti Explosion! 🌟";
            _isGameOver = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                showGameOverDialog();
              }
            });
            return;
          }
        }
      }

      diceRoll = 0;
      // Passes the turn to the next player.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isGameOver) {
          setState(() {
            currentPlayer = (currentPlayer + 1) % players.length;
            status = "${players[currentPlayer].name}'s Turn - Roll to Start";
          });
        }
      });
    });
  }

  // Resets the game to its initial state.
  void resetGame() {
    if (isRolling) return;
    setState(() {
      _isGameOver = false;
      currentPlayer = 0;
      diceRoll = 0;
      isRolling = false;
      hasUsedBoostThisTurn = false;
      status = "${players[currentPlayer].name}'s Turn - Roll to Start";
      for (var player in players) {
        player.pieces = [
          for (var i = 0; i < 4; i++) outOfPlayPositions[player.homeIndex][i],
        ];
        player.finished = 0;
        player.cosmicBoosts = 3;
        player.score = 0;
      }
    });
  }

  // Shows the game over dialog.
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${players[currentPlayer].name} has won the game!"),
              const SizedBox(height: 10),
              ...players.map((p) => Text("${p.name}: ${p.score} points")),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Play Again"),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
            TextButton(
              child: const Text("Exit"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit to player selection
              },
            ),
          ],
        );
      },
    );
  }

  // Builds the out-of-play area for a player.
  Widget buildOutOfPlayArea(int homeIndex, Alignment alignment, bool isHorizontal) {
    int playerIndex = players.indexWhere((p) => p.homeIndex == homeIndex);
    if (playerIndex == -1) return const SizedBox.shrink();

    return Container(
      alignment: alignment,
      child: isHorizontal
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
                    child: players[playerIndex].pieces.any((p) =>
                            p[0] == outOfPlayPositions[homeIndex][i][0] &&
                            p[1] == outOfPlayPositions[homeIndex][i][1])
                        ? GestureDetector(
                            onTap: () {
                              if (!isRolling &&
                                  diceRoll > 0 &&
                                  playerIndex == currentPlayer) {
                                movePiece(
                                  playerIndex,
                                  players[playerIndex].pieces.indexWhere((p) =>
                                      p[0] == outOfPlayPositions[homeIndex][i][0] &&
                                      p[1] == outOfPlayPositions[homeIndex][i][1]),
                                );
                              }
                            },
                            child: AnimalPiece(
                                homeIndex: homeIndex, animation: _pieceAnimation),
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
                    child: players[playerIndex].pieces.any((p) =>
                            p[0] == outOfPlayPositions[homeIndex][i][0] &&
                            p[1] == outOfPlayPositions[homeIndex][i][1])
                        ? GestureDetector(
                            onTap: () {
                              if (!isRolling &&
                                  diceRoll > 0 &&
                                  playerIndex == currentPlayer) {
                                movePiece(
                                  playerIndex,
                                  players[playerIndex].pieces.indexWhere((p) =>
                                      p[0] == outOfPlayPositions[homeIndex][i][0] &&
                                      p[1] == outOfPlayPositions[homeIndex][i][1]),
                                );
                              }
                            },
                            child: AnimalPiece(
                                homeIndex: homeIndex, animation: _pieceAnimation),
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
        child: LayoutBuilder(builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          return Stack(
            children: [
              // Creates a starry background.
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
                child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildOutOfPlayArea(3, Alignment.center, false), // Green
            const SizedBox(height: 20),
            buildOutOfPlayArea(1, Alignment.center, false), // Yellow
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Builds the out-of-play areas for each player.
                buildOutOfPlayArea(2, Alignment.center, true), // Red
              ],
            ),
            // Builds the game board.
            GameBoard(
              players: players,
              currentPlayer: currentPlayer,
              pieceAnimation: _pieceAnimation,
              onPieceTapped: (playerIndex, pieceIndex) {
                if (!isRolling &&
                    diceRoll > 0 &&
                    playerIndex == currentPlayer) {
                  movePiece(
                    playerIndex,
                    pieceIndex,
                    isShortcut: hasUsedBoostThisTurn &&
                        status.contains('shortcut'),
                  );
                }
              },
            ),
            buildOutOfPlayArea(0, Alignment.center, true), // Blue
            const SizedBox(height: 20),
            _buildControls(),
            const SizedBox(height: 10),
            _buildStatusIndicators(),
            const SizedBox(height: 20),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildOutOfPlayArea(2, Alignment.center, false), // Red
            const SizedBox(height: 20),
            buildOutOfPlayArea(0, Alignment.center, false), // Blue
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Builds the out-of-play areas for each player.
            buildOutOfPlayArea(3, Alignment.centerLeft, false), // Green
            const SizedBox(width: 20),
            Column(
              children: [
                buildOutOfPlayArea(2, Alignment.center, true), // Red
                // Builds the game board.
                GameBoard(
                  players: players,
                  currentPlayer: currentPlayer,
                  pieceAnimation: _pieceAnimation,
                  onPieceTapped: (playerIndex, pieceIndex) {
                    if (!isRolling &&
                        diceRoll > 0 &&
                        playerIndex == currentPlayer) {
                      movePiece(
                        playerIndex,
                        pieceIndex,
                        isShortcut: hasUsedBoostThisTurn &&
                            status.contains('shortcut'),
                      );
                    }
                  },
                ),
                buildOutOfPlayArea(0, Alignment.center, true), // Blue
              ],
            ),
            const SizedBox(width: 20),
            buildOutOfPlayArea(1, Alignment.centerRight, false), // Yellow
          ],
        ),
        const SizedBox(height: 20),
        _buildControls(),
        const SizedBox(height: 10),
        _buildStatusIndicators(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildControls() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        // The button to roll the dice.
        ElevatedButton(
          onPressed: diceRoll == 0 && !isRolling ? rollDice : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
          ),
          child: const Text(
            'Roll Dice',
            style: TextStyle(color: Colors.white),
          ),
        ),
        // The dice widget.
        Dice(
          animation: _diceAnimation,
          isRolling: isRolling,
          diceRoll: diceRoll,
        ),
        // The buttons to use the cosmic boosts.
        ElevatedButton(
          onPressed: diceRoll != 0 &&
                  players[currentPlayer].cosmicBoosts > 0 &&
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
        ElevatedButton(
          onPressed: diceRoll != 0 &&
                  players[currentPlayer].cosmicBoosts > 0 &&
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
        ElevatedButton(
          onPressed: diceRoll != 0 &&
                  players[currentPlayer].cosmicBoosts > 0 &&
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
        // The button to reset the game.
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
    );
  }

  Widget _buildStatusIndicators() {
    return Column(
      children: [
        // Displays the number of cosmic boosts the current player has.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cosmic Boosts: ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.yellow, blurRadius: 5),
                ],
              ),
            ),
            for (int i = 0; i < players[currentPlayer].cosmicBoosts; i++)
              const Icon(Icons.star, color: Colors.yellow, size: 20),
          ],
        ),
        const SizedBox(height: 10),
        // Displays the current player's turn and score.
        AnimatedBuilder(
          animation: _indicatorAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _indicatorAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: players[currentPlayer].color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${players[currentPlayer].name}'s Turn (Score: ${players[currentPlayer].score})",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        // Displays the status message.
        Text(
          status,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: [Shadow(color: Colors.yellow, blurRadius: 5)],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// A custom painter that creates a starry background.
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
