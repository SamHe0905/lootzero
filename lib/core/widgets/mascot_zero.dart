import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum ZeroMood { calm, angry, happy }

/// 🧙 Mascote **Zero** — guardião pixel do tesouro.
/// Sprite 20x20 com bevel real (capuz, manto, rosto, olhos, moeda).
/// Tem animação de "respiração" (idle bob) opcional.
class MascotZero extends StatefulWidget {
  const MascotZero({
    super.key,
    this.size = 48,
    this.mood = ZeroMood.calm,
    this.bob = true,
  });

  final double size;
  final ZeroMood mood;
  final bool bob;

  @override
  State<MascotZero> createState() => _MascotZeroState();
}

class _MascotZeroState extends State<MascotZero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.bob) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget sprite = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(painter: _ZeroPainter(mood: widget.mood)),
    );

    if (!widget.bob) return sprite;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -2 * _ctrl.value),
        child: child,
      ),
      child: sprite,
    );
  }
}

class _ZeroPainter extends CustomPainter {
  const _ZeroPainter({required this.mood});
  final ZeroMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 20;
    final s = size.width / grid;

    final hoodHi  = Paint()..color = AppColors.purpleTone;
    final hood    = Paint()..color = AppColors.royalPurple;
    final hoodDk  = Paint()..color = AppColors.purpleDark;
    final hoodDeep= Paint()..color = AppColors.purpleDeep;
    final face    = Paint()..color = const Color(0xFFFFD9A8);
    final faceDk  = Paint()..color = const Color(0xFFE0A77A);
    final coin    = Paint()..color = AppColors.goldCoin;
    final coinHi  = Paint()..color = AppColors.goldTone;
    final coinDk  = Paint()..color = AppColors.goldCoinDk;
    final ink     = Paint()..color = AppColors.ink;
    final mouth   = Paint()..color = AppColors.ink;
    final eyeBase = mood == ZeroMood.angry ? AppColors.rubyRed : AppColors.ink;
    final eye     = Paint()..color = eyeBase;
    final eyeShine= Paint()..color = AppColors.cloudWhite;
    final brow    = mood == ZeroMood.angry ? (Paint()..color = AppColors.ink) : null;

    void px(int x, int y, Paint p) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);

    // Mapa do sprite 20x20.
    // 0 vazio | 1 hood | 2 hoodDk | 3 face | 4 olho | 5 boca
    // 6 moeda | 7 hoodHi | 8 coinHi | 9 coinDk | 10 faceDk | 11 hoodDeep
    const map = <List<int>>[
      [0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,1,7,7,1,1,1,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,1,7,7,1,1,1,1,2,0,0,0,0,0,0],
      [0,0,0,0,0,1,7,7,1,1,1,1,1,2,2,0,0,0,0,0],
      [0,0,0,0,1,7,7,1,3,3,3,3,1,2,2,11,0,0,0,0],
      [0,0,0,1,7,7,1,3,3,3,3,3,3,1,2,11,11,0,0,0],
      [0,0,1,7,7,1,3,3,3,3,3,3,3,3,1,2,11,11,0,0],
      [0,0,1,7,1,3,3,4,4,3,3,4,4,3,1,2,11,0,0,0],
      [0,0,1,1,3,3,3,4,4,3,3,4,4,3,3,1,2,0,0,0],
      [0,0,2,1,3,3,3,3,10,3,3,10,3,3,3,1,2,0,0,0],
      [0,0,2,1,3,3,3,5,5,5,5,5,5,3,3,1,2,0,0,0],
      [0,0,2,2,3,3,3,3,3,3,3,3,3,3,1,2,11,0,0,0],
      [0,0,11,2,2,1,3,3,3,3,3,3,3,1,2,2,11,0,0,0],
      [0,0,11,2,2,2,1,1,1,1,1,1,1,2,2,11,11,0,0,0],
      [0,0,0,11,2,2,2,2,2,2,2,2,2,2,11,11,0,0,0,0],
      [0,0,11,11,2,2,2,8,6,6,6,8,2,2,2,11,11,0,0,0],
      [0,11,2,2,2,2,8,6,6,6,6,6,8,2,2,2,2,11,0,0],
      [0,11,2,2,2,8,6,6,6,8,8,6,6,8,2,2,2,11,0,0],
      [0,11,2,2,2,2,8,6,6,9,9,6,9,2,2,2,2,11,0,0],
      [0,0,11,11,2,2,2,8,9,9,9,9,2,2,2,11,11,0,0,0],
    ];

    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        switch (map[y][x]) {
          case 1: px(x, y, hood);   break;
          case 2: px(x, y, hoodDk); break;
          case 3: px(x, y, face);   break;
          case 4: px(x, y, eye);    break;
          case 5: px(x, y, mouth);  break;
          case 6: px(x, y, coin);   break;
          case 7: px(x, y, hoodHi); break;
          case 8: px(x, y, coinHi); break;
          case 9: px(x, y, coinDk); break;
          case 10: px(x, y, faceDk); break;
          case 11: px(x, y, hoodDeep); break;
        }
      }
    }

    // Brilho nos olhos (1px branco)
    px(8, 7, eyeShine);
    px(12, 7, eyeShine);

    // Sobrancelha franzida quando bravo
    if (brow != null) {
      px(7, 6, brow); px(8, 6, brow);
      px(11, 6, brow); px(12, 6, brow);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeroPainter old) => old.mood != mood;
}
