import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import '../widgets/animal_piece.dart';
import '../widgets/dice.dart';
import '../widgets/game_board.dart';

// The main screen of the game, where the game is played.
class GameScreen extends StatefulWidget {
  // The list of players in the game.
  final List<Player> players;
  const GameScreen({super.key, required this.players});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // A list of players in the game.
  late List<Player> players;
  // Animation controllers and animations for the pieces, dice, and indicators.
  late AnimationController _pieceAnimationController;
  late AnimationController _diceAnimationController;
  late Animation<double> _diceAnimation;
  late AnimationController _starAnimationController;

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    final customCurve = Curves.elasticOut;
    _diceAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _diceAnimationController, curve: customCurve))
      ..addListener(() {
        if (mounted) setState(() {});
      });

    // Initializes the players.
    players = widget.players;

    // Sets the initial status message.
    status = "${players[currentPlayer].name}'s Turn - Roll to Start";
  }

  @override
  void dispose() {
    // Disposes the animation controllers.
    _pieceAnimationController.dispose();
    _diceAnimationController.dispose();
    _starAnimationController.dispose();
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
      players[currentPlayer] = players[currentPlayer].copyWith(
        cosmicBoosts: players[currentPlayer].cosmicBoosts - 1,
      );
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
      List<List<int>> newPieces = List.from(player.pieces);

      // If the piece is out of play, it can be moved if the dice roll is 6.
      if (piece[0] < 0 || piece[0] >= gridSize || piece[1] < 0 || piece[1] >= gridSize) {
        if (diceRoll == 6) {
          newPieces[pieceIndex] = path[0];
          players[playerIndex] = player.copyWith(pieces: newPieces);
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

        newPieces[pieceIndex] = path[newIndex];
        players[playerIndex] = player.copyWith(pieces: newPieces);

        // If the piece lands on an opponent's piece, the opponent's piece is sent back to its home.
        if (!safeZones.any((s) => s[0] == path[newIndex][0] && s[1] == path[newIndex][1])) {
          for (var i = 0; i < players.length; i++) {
            if (i != playerIndex) {
              var opponent = players[i];
              List<List<int>> opponentPieces = List.from(opponent.pieces);
              bool captured = false;
              for (int j = 0; j < opponent.pieces.length; j++) {
                if (opponent.pieces[j][0] == path[newIndex][0] &&
                    opponent.pieces[j][1] == path[newIndex][1]) {
                  opponentPieces[j] = outOfPlayPositions[opponent.homeIndex][j];
                  captured = true;
                }
              }
              if (captured) {
                players[i] = opponent.copyWith(pieces: opponentPieces);
                status = "${player.name} captured ${opponent.name}'s piece!";
              }
            }
          }
        }

        status = "${player.name} moved to (${newPieces[pieceIndex][0]}, ${newPieces[pieceIndex][1]})";
        // If the piece reaches the flag, the player's score is increased.
        if (newPieces[pieceIndex] == flag) {
          status = "${player.name}'s piece reached the Cosmic Flag! 🎉";
          players[playerIndex] = player.copyWith(
            finished: player.finished + 1,
            score: player.score + 10,
          );
          // If all of the player's pieces have reached the flag, the game is over.
          if (players[playerIndex].finished == 4) {
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
      for (var i = 0; i < players.length; i++) {
        players[i] = players[i].copyWith(
          pieces: [
            for (var j = 0; j < 4; j++) outOfPlayPositions[players[i].homeIndex][j],
          ],
          finished: 0,
          cosmicBoosts: 3,
          score: 0,
        );
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
          backgroundColor: Colors.deepPurple.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.yellow, width: 2),
          ),
          title: Center(
            child: Text(
              "Victory!",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${players[currentPlayer].name} has conquered the cosmos!",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...players.map((p) => Text(
                    "${p.name}: ${p.score} points",
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
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
  Widget buildOutOfPlayArea(
    int homeIndex,
    Alignment alignment,
    bool isHorizontal,
    Animation<double> animation,
  ) {
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
                              homeIndex: homeIndex,
                              animation: animation,
                            ),
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
                              homeIndex: homeIndex,
                              animation: animation,
                            ),
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
        title: Text('Cosmo Quest', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
          bool isWide = constraints.maxWidth > 700;
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _starAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: StarryBackgroundPainter(animationValue: _starAnimationController.value),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                if (players.any((p) => p.homeIndex == 1))
                  buildOutOfPlayArea(
                    1,
                    Alignment.center,
                    true,
                    CurvedAnimation(
                      parent: _pieceAnimationController,
                      curve: Curves.easeIn,
                    ),
                  ), // Red
                // Builds the game board.
                GameBoard(
                  players: players,
                  currentPlayer: currentPlayer,
                  pieceAnimation: CurvedAnimation(
                    parent: _pieceAnimationController,
                    curve: Curves.easeOut,
                  ),
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
                if (players.any((p) => p.homeIndex == 0))
                  buildOutOfPlayArea(
                    0,
                    Alignment.center,
                    true,
                    CurvedAnimation(
                      parent: _pieceAnimationController,
                      curve: Curves.elasticIn,
                    ),
                  ), // Blue
                const SizedBox(height: 20),
                _buildControls(),
                const SizedBox(height: 20),
                _buildStatusIndicators(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Builds the out-of-play areas for each player.
          if (players.any((p) => p.homeIndex == 1))
            buildOutOfPlayArea(
              1,
              Alignment.center,
              true,
              CurvedAnimation(
                parent: _pieceAnimationController,
                curve: Curves.easeIn,
              ),
            ), // Red
          const SizedBox(height: 20),
          // Builds the game board.
          GameBoard(
            players: players,
            currentPlayer: currentPlayer,
            pieceAnimation: CurvedAnimation(
              parent: _pieceAnimationController,
              curve: Curves.easeOut,
            ),
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
          const SizedBox(height: 20),
          if (players.any((p) => p.homeIndex == 0))
            buildOutOfPlayArea(
              0,
              Alignment.center,
              true,
              CurvedAnimation(
                parent: _pieceAnimationController,
                curve: Curves.elasticIn,
              ),
            ), // Blue
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 20),
          _buildStatusIndicators(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton.icon(
            onPressed: diceRoll == 0 && !isRolling ? rollDice : null,
            icon: const Icon(Icons.casino, color: Colors.white),
            label: const Text('Roll Dice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Dice(
            animation: _diceAnimation,
            isRolling: isRolling,
            diceRoll: diceRoll,
          ),
          ..._buildCosmicBoostButtons(),
          ElevatedButton.icon(
            onPressed: !isRolling ? resetGame : null,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCosmicBoostButtons() {
    bool canUseBoost = diceRoll != 0 &&
        players[currentPlayer].cosmicBoosts > 0 &&
        !hasUsedBoostThisTurn &&
        !isRolling;
    return [
      ElevatedButton(
        onPressed: canUseBoost ? () => useCosmicBoost('reroll') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.black,
        ),
        child: const Text('Reroll'),
      ),
      ElevatedButton(
        onPressed: canUseBoost ? () => useCosmicBoost('shortcut') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.black,
        ),
        child: const Text('Shortcut'),
      ),
      ElevatedButton(
        onPressed: canUseBoost ? () => useCosmicBoost('double') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.black,
        ),
        child: const Text('Double'),
      ),
    ];
  }

  Widget _buildStatusIndicators() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.yellow.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cosmic Boosts: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              for (int i = 0; i < players[currentPlayer].cosmicBoosts; i++)
                const Icon(Icons.star, color: Colors.yellow, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 15),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: players[currentPlayer].color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: players[currentPlayer].color.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            "${players[currentPlayer].name}'s Turn (Score: ${players[currentPlayer].score})",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          status,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class StarryBackgroundPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;

  StarryBackgroundPainter({required this.animationValue}) : stars = _generateStars(200);

  static List<Star> _generateStars(int count) {
    final random = Random();
    return List.generate(count, (index) {
      return Star(
        offset: Offset(random.nextDouble(), random.nextDouble()),
        radius: random.nextDouble() * 2.5,
        twinkleSpeed: random.nextDouble() * 0.5 + 0.5, // Varies the speed of the twinkle
        twinkleOffset: random.nextDouble(), // Ensures stars don't all twinkle at once
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(
          (0.5 + 0.5 * sin(2 * pi * (animationValue * star.twinkleSpeed + star.twinkleOffset))).clamp(0.1, 1.0),
        );
      canvas.drawCircle(
        Offset(star.offset.dx * size.width, star.offset.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarryBackgroundPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

class Star {
  final Offset offset;
  final double radius;
  final double twinkleSpeed;
  final double twinkleOffset;

  Star({
    required this.offset,
    required this.radius,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}
