import 'package:flutter/material.dart';

class DiceDot extends StatelessWidget {
  final int count;
  final double size;

  const DiceDot({super.key, required this.count, required this.size});

  // A map to store the dot patterns for each dice value.
  static const Map<int, List<int>> _dotPatterns = {
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: size * 0.1,
      crossAxisSpacing: size * 0.1,
      children: List.generate(9, (index) {
        final isVisible = _dotPatterns[count]?.contains(index) ?? false;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isVisible ? Colors.black : Colors.transparent,
          ),
        );
      }),
    );
  }
}
