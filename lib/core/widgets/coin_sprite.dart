import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 🪙 Moeda dourada animada — gira no eixo Y (efeito flip pixel-art).
/// Substitui o emoji em todo o app.
class CoinSprite extends StatefulWidget {
  const CoinSprite({super.key, this.size = 32, this.spin = true});
  final double size;
  final bool spin;

  @override
  State<CoinSprite> createState() => _CoinSpriteState();
}

class _CoinSpriteState extends State<CoinSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.spin) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.spin) return _Coin(scale: 1, size: widget.size);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        // Ciclo: 1 → 0.1 → 1 (flip)
        final scale = (t < 0.5)
            ? (1 - t * 1.8).clamp(0.1, 1.0)
            : ((t - 0.5) * 1.8 + 0.1).clamp(0.1, 1.0);
        // Inverte cores na metade (efeito "verso da moeda")
        final flipped = t > 0.5;
        return _Coin(scale: scale, flipped: flipped, size: widget.size);
      },
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.scale, required this.size, this.flipped = false});
  final double scale;
  final double size;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(scale, 1.0),
        child: CustomPaint(painter: _CoinPainter(flipped: flipped)),
      ),
    );
  }
}

class _CoinPainter extends CustomPainter {
  _CoinPainter({required this.flipped});
  final bool flipped;

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 16;
    final s = size.width / grid;
    final gold     = Paint()..color = AppColors.goldCoin;
    final goldHi   = Paint()..color = AppColors.goldTone;
    final goldDk   = Paint()..color = AppColors.goldCoinDk;
    final goldDeep = Paint()..color = AppColors.goldDeep;
    final ink      = Paint()..color = AppColors.ink;
    final accent   = Paint()..color = flipped ? AppColors.rubyDark : AppColors.royalPurple;

    void px(int x, int y, Paint p) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);

    // 0 vazio | 1 ink | 2 gold | 3 highlight | 4 shadow | 5 deep shadow | 6 accent
    const map = <List<int>>[
      [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
      [0,0,1,1,3,3,2,2,2,2,2,2,1,1,0,0],
      [0,1,3,3,3,2,2,2,2,2,2,4,4,4,1,0],
      [0,1,3,2,2,2,6,2,2,6,2,2,2,4,1,0],
      [1,3,3,2,6,2,2,2,2,2,2,6,2,4,4,1],
      [1,3,2,2,6,2,2,2,2,2,2,6,2,2,4,1],
      [1,3,2,2,2,6,2,2,2,2,6,2,2,2,4,1],
      [1,3,2,2,2,2,6,2,2,6,2,2,2,2,4,1],
      [1,3,2,2,2,2,2,6,6,2,2,2,2,2,4,1],
      [1,3,2,2,6,2,2,2,2,2,2,6,2,2,4,1],
      [1,3,2,2,6,2,2,2,2,2,2,6,2,2,4,1],
      [1,3,2,2,2,6,2,2,2,2,6,2,2,2,4,1],
      [0,1,3,2,2,2,6,6,6,6,2,2,2,4,1,0],
      [0,1,3,3,2,2,2,2,2,2,2,2,4,5,1,0],
      [0,0,1,1,3,2,2,2,2,2,2,4,5,1,1,0],
      [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
    ];

    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        switch (map[y][x]) {
          case 1: px(x, y, ink);    break;
          case 2: px(x, y, gold);   break;
          case 3: px(x, y, goldHi); break;
          case 4: px(x, y, goldDk); break;
          case 5: px(x, y, goldDeep); break;
          case 6: px(x, y, accent); break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) => old.flipped != flipped;
}
