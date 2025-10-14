import 'package:flutter/material.dart';
import 'dice_dot.dart';

class DiceFace extends StatelessWidget {
  final int value;
  final double size;

  const DiceFace(this.value, {super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: switch (value) {
        1 => DiceDot(count: 1, size: size),
        2 => DiceDot(count: 2, size: size),
        3 => DiceDot(count: 3, size: size),
        4 => DiceDot(count: 4, size: size),
        5 => DiceDot(count: 5, size: size),
        6 => DiceDot(count: 6, size: size),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
