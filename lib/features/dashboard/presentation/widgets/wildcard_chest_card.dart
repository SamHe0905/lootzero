import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/pixel_container.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../domain/entities/envelope.dart';

/// 🎁 **Baú Curinga** — Fundo YOLO.
/// Card limpo: tap leva à tela de detalhe (REFORÇAR/REGISTRAR GASTO ficam lá).
class WildcardChestCard extends StatelessWidget {
  const WildcardChestCard({
    super.key,
    required this.yolo,
    required this.onTap,
  });

  final Envelope yolo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final broke = yolo.isBroke;
    final fill = yolo.allocated == 0
        ? 0.0
        : (yolo.available / yolo.allocated).clamp(0.0, 1.0);

    return PixelContainer(
      fill: broke ? AppColors.chestWoodDk : AppColors.chestGold,
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 14),
      onTap: () {
        if (broke) {
          HapticService.error();
        } else {
          HapticService.coin();
        }
        onTap();
      },
      child: Row(
        children: [
          ChestSprite(broke: broke, fillRatio: fill, size: 84),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  broke ? 'BAÚ VAZIO' : 'BAÚ CURINGA',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: broke ? AppColors.cloudWhite : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  broke
                      ? 'Sem moedas pra impulso'
                      : 'Fundo YOLO • ${(fill * 100).round()}% cheio',
                  style: AppTextStyles.caption.copyWith(
                    color: broke
                        ? AppColors.cloudWhite.withOpacity(0.85)
                        : AppColors.inkLight,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DISPONÍVEL',
                    style: AppTextStyles.badge.copyWith(
                        color:
                            broke ? AppColors.cloudWhite : AppColors.ink)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    money(yolo.available),
                    style: AppTextStyles.moneySmall.copyWith(
                      color: broke ? AppColors.rubyTone : AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SPRITE DO BAÚ (open/broke) — sem mudanças
// ============================================================

class ChestSprite extends StatefulWidget {
  const ChestSprite({
    super.key,
    required this.broke,
    this.size = 72,
    this.fillRatio = 1.0,
  });

  final bool broke;
  final double size;
  final double fillRatio;

  @override
  State<ChestSprite> createState() => _ChestSpriteState();
}

class _ChestSpriteState extends State<ChestSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    if (!widget.broke) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 16 / 20,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: widget.broke
              ? _BrokeChestPainter(glow: _ctrl.value)
              : _OpenChestPainter(
                  fillRatio: widget.fillRatio,
                  glow: _ctrl.value,
                ),
        ),
      ),
    );
  }
}

class _OpenChestPainter extends CustomPainter {
  _OpenChestPainter({required this.fillRatio, required this.glow});
  final double fillRatio;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 20, rows = 16;
    final s = size.width / cols;

    final wood    = Paint()..color = AppColors.chestWood;
    final woodHi  = Paint()..color = AppColors.lighten(AppColors.chestWood, 0.12);
    final woodDk  = Paint()..color = AppColors.chestWoodDk;
    final gold    = Paint()..color = AppColors.goldCoin;
    final goldHi  = Paint()..color = AppColors.goldTone;
    final goldDk  = Paint()..color = AppColors.goldCoinDk;
    final ink     = Paint()..color = AppColors.ink;
    final inside  = Paint()..color = const Color(0xFF2A1810);
    final coin    = Paint()..color = AppColors.goldCoin;
    final coinHi  = Paint()..color = AppColors.goldTone;
    final coinDk  = Paint()..color = AppColors.goldCoinDk;
    final coinDeep= Paint()..color = AppColors.goldDeep;
    final gemColor = Color.lerp(
        AppColors.purpleTone, AppColors.royalPurple, glow)!;
    final gem    = Paint()..color = gemColor;
    final gemHi  = Paint()..color = AppColors.cloudWhite;

    void px(int x, int y, Paint p) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);

    const map = <List<int>>[
      [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0],
      [0,0,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,0,0],
      [0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0],
      [0,1,2,4,2,2,3,2,2,2,2,2,2,3,2,2,4,2,1,0],
      [0,1,2,5,6,5,5,5,5,5,5,5,5,5,5,6,5,2,1,0],
      [1,2,5,7,8,8,8,8,8,8,8,8,8,8,8,8,7,5,2,1],
      [1,2,3,5,8,8,8,8,8,8,8,8,8,8,8,8,5,3,2,1],
      [1,2,2,5,8,8,8,8,8,8,8,8,8,8,8,8,5,2,2,1],
      [1,2,3,5,8,8,8,8,8,8,8,8,8,8,8,8,5,3,2,1],
      [1,2,2,5,8,8,8,8,8,8,8,8,8,8,8,8,5,2,2,1],
      [1,2,3,5,8,8,8,8,8,8,8,8,8,8,8,8,5,3,2,1],
      [1,2,2,5,7,7,7,7,7,7,7,7,7,7,7,7,5,2,2,1],
      [1,2,4,5,1,1,1,1,1,1,1,1,1,1,1,1,5,4,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0],
    ];

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        switch (map[y][x]) {
          case 1: px(x, y, ink);    break;
          case 2: px(x, y, wood);   break;
          case 3: px(x, y, woodHi); break;
          case 4: px(x, y, woodDk); break;
          case 5: px(x, y, gold);   break;
          case 6: px(x, y, goldHi); break;
          case 7: px(x, y, goldDk); break;
          case 8: px(x, y, inside); break;
        }
      }
    }

    final coinRows = (fillRatio * 5).round().clamp(0, 5);
    const interiorXStart = 4;
    const interiorXEnd = 15;

    for (var r = 0; r < coinRows; r++) {
      final y = 11 - r;
      for (var x = interiorXStart; x <= interiorXEnd; x++) {
        final col = (x - interiorXStart);
        final stripe = (col + r) % 3;
        Paint p;
        switch (stripe) {
          case 0: p = coinHi; break;
          case 1: p = coin;   break;
          default: p = coinDk;
        }
        if ((col % 4 == 3) && r > 0) p = coinDeep;
        px(x, y, p);
      }
    }

    if (fillRatio > 0.8) {
      px(8, 5, coinHi); px(9, 5, coin); px(10, 5, coinDk);
      px(11, 5, coin);
      px(3, 6, coinHi); px(3, 7, coin);
      px(16, 6, coin); px(16, 7, coinDk);
    }

    px(9, 3, gem);
    px(10, 3, gem);
    px(9, 4, gemHi);
    px(10, 4, gem);

    if (fillRatio > 0.5) {
      final glowP = Paint()
        ..color = AppColors.goldTone
            .withOpacity(0.20 + 0.30 * glow * (fillRatio - 0.5) * 2);
      canvas.drawCircle(
        Offset(10 * s, 8 * s),
        7 * s,
        glowP
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OpenChestPainter old) =>
      old.fillRatio != fillRatio || old.glow != glow;
}

class _BrokeChestPainter extends CustomPainter {
  _BrokeChestPainter({required this.glow});
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 20, rows = 16;
    final s = size.width / cols;

    final wood   = Paint()..color = AppColors.brokenStone;
    final woodHi = Paint()..color = AppColors.lighten(AppColors.brokenStone, 0.10);
    final woodDk = Paint()..color = const Color(0xFF6E2A18);
    final iron   = Paint()..color = AppColors.citadelStoneDk;
    final ink    = Paint()..color = AppColors.ink;
    final cross  = Paint()..color = AppColors.rubyRed;

    void px(int x, int y, Paint p) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);

    const map = <List<int>>[
      [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
      [0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0],
      [1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1],
      [1,2,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,1],
      [1,2,4,2,2,2,2,2,2,4,4,4,2,2,2,2,2,4,2,1],
      [1,1,1,1,1,1,1,1,1,5,5,5,1,1,1,1,1,1,1,1],
      [1,2,2,2,2,2,2,4,5,5,5,5,5,4,2,2,2,2,2,1],
      [1,2,4,2,2,2,4,5,5,5,5,5,5,5,4,2,2,4,2,1],
      [1,2,2,2,2,4,5,5,5,5,5,5,5,5,5,4,2,2,2,1],
      [1,2,2,4,2,2,4,5,5,5,5,5,5,5,4,2,2,2,2,1],
      [1,2,4,2,2,2,2,4,5,5,5,5,5,4,2,2,2,4,2,1],
      [1,2,2,2,2,2,2,2,4,4,4,4,4,2,2,2,2,2,2,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        switch (map[y][x]) {
          case 1: px(x, y, ink);    break;
          case 2: px(x, y, wood);   break;
          case 3: px(x, y, woodHi); break;
          case 4: px(x, y, woodDk); break;
          case 5: px(x, y, iron);   break;
        }
      }
    }

    void cross1(int x, int y) {
      px(x, y, cross); px(x + 1, y + 1, cross);
      px(x + 2, y + 2, cross); px(x + 3, y + 3, cross);
    }
    void cross2(int x, int y) {
      px(x + 3, y, cross); px(x + 2, y + 1, cross);
      px(x + 1, y + 2, cross); px(x, y + 3, cross);
    }
    cross1(8, 7);
    cross2(8, 7);
  }

  @override
  bool shouldRepaint(covariant _BrokeChestPainter old) => old.glow != glow;
}
