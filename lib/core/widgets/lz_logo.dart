import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Logo Loot Zero — letras "LZ" em pixel-art com moeda no fundo.
class LzLogo extends StatelessWidget {
  const LzLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LzPainter()),
    );
  }
}

class _LzPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const grid = 16;
    final s = size.width / grid;
    final coin   = Paint()..color = AppColors.goldCoin;
    final coinDk = Paint()..color = AppColors.goldCoinDk;
    final ink    = Paint()..color = AppColors.ink;
    final purple = Paint()..color = AppColors.royalPurple;

    void px(int x, int y, Paint p) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);

    // 0 vazio | 1 moeda | 2 sombra moeda | 3 contorno | 4 letras roxas
    const map = <List<int>>[
      [0,0,0,3,3,3,3,3,3,3,3,3,3,0,0,0],
      [0,0,3,1,1,1,1,1,1,1,1,1,1,3,0,0],
      [0,3,1,1,1,1,1,1,1,1,1,1,1,1,3,0],
      [3,1,1,4,1,1,1,1,1,1,1,1,4,1,1,3],
      [3,1,1,4,1,1,4,4,4,4,1,1,4,1,1,3],
      [3,1,1,4,1,1,1,1,1,4,1,1,4,1,1,3],
      [3,1,1,4,1,1,1,1,4,1,1,4,4,1,1,3],
      [3,1,1,4,1,1,1,4,1,1,1,1,4,1,1,3],
      [3,1,1,4,1,1,4,1,1,1,1,1,4,1,1,3],
      [3,1,1,4,4,4,4,4,4,4,1,4,4,1,1,3],
      [3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3],
      [3,2,1,1,1,1,1,1,1,1,1,1,1,1,2,3],
      [0,3,2,2,1,1,1,1,1,1,1,1,2,2,3,0],
      [0,0,3,2,2,2,2,2,2,2,2,2,2,3,0,0],
      [0,0,0,3,3,3,3,3,3,3,3,3,3,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        switch (map[y][x]) {
          case 1: px(x, y, coin);   break;
          case 2: px(x, y, coinDk); break;
          case 3: px(x, y, ink);    break;
          case 4: px(x, y, purple); break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
