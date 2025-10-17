import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import '../widgets/animal_piece.dart';
import '../widgets/dice.dart';
import '../widgets/game_board.dart';

extension on List<int> {
  bool get isOutOfPlay => any((coord) => coord < 0 || coord >= gridSize);
}

class GameScreen extends StatefulWidget {
  final List<Player> players;
  const GameScreen({super.key, required this.players});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<Player> players;
  late AnimationController _diceAnimationController;
  late Animation<double> _diceAnimation;
  late AnimationController _starAnimationController;

  int diceRoll = 0;
  bool isRolling = false;
  int currentPlayerIndex = 0;
  String status = "";
  bool hasUsedBoostThisTurn = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    players = widget.players;

    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _diceAnimation = CurvedAnimation(
      parent: _diceAnimationController,
      curve: Curves.elasticOut,
    )..addListener(() => setState(() {}));

    status = "${players[currentPlayerIndex].name}'s Turn - Roll to Start";
  }

  @override
  void dispose() {
    _diceAnimationController.dispose();
    _starAnimationController.dispose();
    super.dispose();
  }

  bool isCellBlocked(List<int> cellCoords) {
    int occupants = 0;
    for (var p in players) {
      for (var piece in p.pieces) {
        if (piece[0] == cellCoords[0] && piece[1] == cellCoords[1]) {
          occupants++;
        }
      }
    }
    return occupants >= 2;
  }

  bool canMovePiece() {
    final player = players[currentPlayerIndex];
    final path = spiralPaths[player.homeIndex];

    for (var piece in player.pieces) {
      if (piece.isOutOfPlay) {
        if (diceRoll == 6) return true;
      } else {
        final currentIndex = path.indexWhere((p) => p[0] == piece[0] && p[1] == piece[1]);
        if (currentIndex != -1) {
          final newIndex = currentIndex + diceRoll;
          if (newIndex < path.length && !isCellBlocked(path[newIndex])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void rollDice() {
    if (isRolling || _isGameOver) return;
    setState(() {
      isRolling = true;
      _diceAnimationController.forward(from: 0).then((_) {
        if (!mounted) return;
        setState(() {
          diceRoll = Random().nextInt(6) + 1;
          isRolling = false;
          hasUsedBoostThisTurn = false;
          status = "${players[currentPlayerIndex].name} rolled a $diceRoll";
          if (!canMovePiece()) {
            status += " - No moves possible!";
            _passTurn();
          } else {
            status += " - Tap a piece to move";
          }
        });
      });
    });
  }

  void movePiece(int pieceIndex, {bool isShortcut = false}) {
    if (diceRoll == 0 || isRolling || !mounted || _isGameOver) return;

    var player = players[currentPlayerIndex];
    var piece = player.pieces[pieceIndex];
    var path = spiralPaths[player.homeIndex];

    if (piece.isOutOfPlay) {
      if (diceRoll == 6) {
        setState(() {
          _updatePiecePosition(currentPlayerIndex, pieceIndex, path[0]);
          status = "${player.name} moved a piece onto the board!";
          _passTurn();
        });
      } else {
        setState(() {
          status = "Needs a 6 to bring a piece into play!";
          _passTurn();
        });
      }
      return;
    }

    final currentIndex = path.indexWhere((p) => p[0] == piece[0] && p[1] == piece[1]);
    if (currentIndex != -1) {
      int newIndex = isShortcut ? currentIndex + 1 : currentIndex + diceRoll;

      if (newIndex >= path.length) {
        setState(() {
          status = "Overshot the flag - exact roll needed!";
          _passTurn();
        });
        return;
      }

      final newPosition = path[newIndex];
      if (isCellBlocked(newPosition)) {
        setState(() {
          status = "Path blocked! You cannot move there.";
          _passTurn();
        });
        return;
      }

      setState(() {
        _updatePiecePosition(currentPlayerIndex, pieceIndex, newPosition);
        _handleCapture(newPosition);

        if (newPosition[0] == flag[0] && newPosition[1] == flag[1]) {
          player = players[currentPlayerIndex].copyWith(
            finished: players[currentPlayerIndex].finished + 1,
            score: players[currentPlayerIndex].score + 10,
          );
          players[currentPlayerIndex] = player;
          status = "${player.name}'s piece reached the Cosmic Flag! 🎉";

          if (player.finished == 4) {
            _handleGameOver();
          } else {
            _passTurn();
          }
        } else {
          _passTurn();
        }
      });
    }
  }

  void _updatePiecePosition(int pIndex, int pieceIdx, List<int> newPos) {
    List<List<int>> newPieces = List.from(players[pIndex].pieces);
    newPieces[pieceIdx] = newPos;
    players[pIndex] = players[pIndex].copyWith(pieces: newPieces);
  }

  void _handleCapture(List<int> position) {
    if (safeZones.any((sz) => sz[0] == position[0] && sz[1] == position[1])) return;

    final opponentIndex = 1 - currentPlayerIndex;
    var opponent = players[opponentIndex];
    var opponentPieces = List<List<int>>.from(opponent.pieces);
    bool captured = false;

    for (int j = 0; j < opponentPieces.length; j++) {
      if (opponentPieces[j][0] == position[0] && opponentPieces[j][1] == position[1]) {
        opponentPieces[j] = outOfPlayPositions[opponent.homeIndex][j];
        captured = true;
      }
    }

    if (captured) {
      players[opponentIndex] = opponent.copyWith(pieces: opponentPieces);
      status = "${players[currentPlayerIndex].name} captured ${opponent.name}'s piece!";
    }
  }

  void _passTurn() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_isGameOver) {
        setState(() {
          currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
          diceRoll = 0;
          hasUsedBoostThisTurn = false;
          status = "${players[currentPlayerIndex].name}'s Turn - Roll to Start";
        });
      }
    });
  }

  void _handleGameOver() {
    setState(() {
      _isGameOver = true;
      status = "${players[currentPlayerIndex].name} Wins! 🌟 Confetti Explosion! 🌟";
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) showGameOverDialog();
    });
  }

  void resetGame() {
    if (isRolling) return;
    setState(() {
      _isGameOver = false;
      currentPlayerIndex = 0;
      diceRoll = 0;
      isRolling = false;
      hasUsedBoostThisTurn = false;
      for (var i = 0; i < players.length; i++) {
        players[i] = players[i].copyWith(
          pieces: List.generate(4, (j) => outOfPlayPositions[players[i].homeIndex][j]),
          finished: 0,
          cosmicBoosts: 3,
          score: 0,
        );
      }
      status = "${players.first.name}'s Turn - Roll to Start";
    });
  }

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
          title: Center(child: Text("Victory!", style: Theme.of(context).textTheme.headlineSmall)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${players[currentPlayerIndex].name} has conquered the cosmos!",
                  style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ...players.map((p) => Text("${p.name}: ${p.score} points", style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
          actions: <Widget>[
            TextButton(child: const Text("Play Again"), onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            }),
            TextButton(child: const Text("Exit"), onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
          ],
        );
      },
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
          gradient: LinearGradient(colors: [Colors.black, Colors.blueGrey.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _starAnimationController,
                  builder: (context, child) => CustomPaint(painter: StarryBackgroundPainter(animationValue: _starAnimationController.value)),
                ),
              ),
              Padding(padding: const EdgeInsets.all(16.0), child: isWide ? _buildWideLayout() : _buildNarrowLayout()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerAreas(),
              const SizedBox(height: 20),
              _buildStatusIndicators(),
            ],
          ),
        ),
        const Spacer(),
        Expanded(flex: 1, child: _buildControlsColumn()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPlayerAreas(),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 20),
          _buildStatusIndicators(),
        ],
      ),
    );
  }

  Widget _buildPlayerAreas() {
    return Column(
      children: [
        if (players.length > 1) buildOutOfPlayArea(1),
        const SizedBox(height: 20),
        _buildGameBoard(),
        const SizedBox(height: 20),
        if (players.isNotEmpty) buildOutOfPlayArea(0),
      ],
    );
  }

  Widget _buildGameBoard() {
    return GameBoard(
      players: players,
      currentPlayerIndex: currentPlayerIndex,
      diceRoll: diceRoll,
      onPieceTapped: (playerIndex, pieceIndex) {
        if (playerIndex == currentPlayerIndex) {
          movePiece(pieceIndex);
        }
      },
    );
  }

  Widget buildOutOfPlayArea(int homeIndex) {
    final playerIndex = players.indexWhere((p) => p.homeIndex == homeIndex);
    if (playerIndex == -1) return const SizedBox.shrink();

    final player = players[playerIndex];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final pieceCoords = outOfPlayPositions[homeIndex][i];
          final pieceIndex = player.pieces.indexWhere((p) => p[0] == pieceCoords[0] && p[1] == pieceCoords[1]);
          final isPieceHere = pieceIndex != -1;
          final isSelectable = isPieceHere && playerIndex == currentPlayerIndex && diceRoll == 6;

          return GestureDetector(
            onTap: () {
              if (isPieceHere && playerIndex == currentPlayerIndex) {
                movePiece(pieceIndex);
              }
            },
            child: Container(
              width: 40, height: 40, margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors.grey.shade800, borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white.withOpacity(0.5))),
              child: isPieceHere ? AnimalPiece(homeIndex: homeIndex, isSelectable: isSelectable) : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControlsColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControls(),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: !isRolling ? resetGame : null,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(15)),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12, runSpacing: 12, verticalDirection: VerticalDirection.up,
        children: [
          ElevatedButton.icon(
            onPressed: diceRoll == 0 && !isRolling ? rollDice : null,
            icon: const Icon(Icons.casino, color: Colors.white),
            label: const Text('Roll Dice'),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
          ),
          Dice(animation: _diceAnimation, isRolling: isRolling, diceRoll: diceRoll),
          ..._buildCosmicBoostButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildCosmicBoostButtons() {
    bool canUseBoost = diceRoll > 0 && players[currentPlayerIndex].cosmicBoosts > 0 && !hasUsedBoostThisTurn && !isRolling;
    return [
      ElevatedButton(onPressed: canUseBoost ? () => useCosmicBoost('reroll') : null, child: const Text('Reroll')),
      ElevatedButton(onPressed: canUseBoost ? () => useCosmicBoost('shortcut') : null, child: const Text('Shortcut')),
      ElevatedButton(onPressed: canUseBoost ? () => useCosmicBoost('double') : null, child: const Text('Double')),
    ];
  }
  
  void useCosmicBoost(String type) {
    if (diceRoll == 0 || players[currentPlayerIndex].cosmicBoosts <= 0 || hasUsedBoostThisTurn || isRolling) {
      return;
    }
    setState(() {
      players[currentPlayerIndex] = players[currentPlayerIndex].copyWith(
        cosmicBoosts: players[currentPlayerIndex].cosmicBoosts - 1,
      );
      hasUsedBoostThisTurn = true;
      switch (type) {
        case 'reroll':
          isRolling = true;
          _diceAnimationController.forward(from: 0).then((_) {
            if (!mounted) return;
            setState(() {
              diceRoll = Random().nextInt(6) + 1;
              isRolling = false;
              status = "${players[currentPlayerIndex].name}'s Turn - Rerolled a $diceRoll - Tap a piece to move";
            });
          });
          break;
        case 'shortcut':
          status = "${players[currentPlayerIndex].name}'s Turn - Use shortcut by tapping a piece";
          break;
        case 'double':
          diceRoll *= 2;
          status = "${players[currentPlayerIndex].name}'s Turn - Doubled to $diceRoll - Tap a piece to move";
          break;
      }
    });
  }

  Widget _buildStatusIndicators() {
    final currentPlayer = players[currentPlayerIndex];
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
              Text('Cosmic Boosts: ', style: Theme.of(context).textTheme.bodyLarge),
              for (int i = 0; i < currentPlayer.cosmicBoosts; i++) const Icon(Icons.star, color: Colors.yellow, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 15),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: currentPlayer.color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: currentPlayer.color.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Text("${currentPlayer.name}'s Turn (Score: ${currentPlayer.score})", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
        ),
        const SizedBox(height: 15),
        Text(status, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
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
        twinkleSpeed: random.nextDouble() * 0.5 + 0.5,
        twinkleOffset: random.nextDouble(),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()..color = Colors.white.withOpacity((0.5 + 0.5 * sin(2 * pi * (animationValue * star.twinkleSpeed + star.twinkleOffset))).clamp(0.1, 1.0));
      canvas.drawCircle(Offset(star.offset.dx * size.width, star.offset.dy * size.height), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarryBackgroundPainter oldDelegate) => animationValue != oldDelegate.animationValue;
}

class Star {
  final Offset offset;
  final double radius;
  final double twinkleSpeed;
  final double twinkleOffset;

  Star({required this.offset, required this.radius, required this.twinkleSpeed, required this.twinkleOffset});
}
