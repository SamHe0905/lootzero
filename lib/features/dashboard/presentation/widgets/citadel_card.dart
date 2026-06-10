import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/pixel_container.dart';
import '../../../../core/widgets/pixel_progress_bar.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../domain/entities/citadel_goal.dart';

/// 🏯 **A Cidadela** — A Grande Meta.
/// Torre fortificada com bandeira ondulando (animação de waving flag).
class CitadelCard extends StatelessWidget {
  const CitadelCard({super.key, required this.goal});
  final CitadelGoal goal;

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).round();
    return PixelContainer(
      fill: AppColors.parchment,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CitadelSprite(size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A CIDADELA', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 6),
                    Text('Sua grande meta', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: PixelDecorations.box(
                    fill: AppColors.goldCoin, shadow: false),
                child: Text('$pct%', style: AppTextStyles.badge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PixelProgressBar(value: goal.progress, fill: AppColors.emerald),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('GUARDADO', style: AppTextStyles.badge),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(money(goal.saved),
                          style: AppTextStyles.moneySmall
                              .copyWith(color: AppColors.emeraldDark)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('FALTAM', style: AppTextStyles.badge),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(money(goal.remaining),
                          style: AppTextStyles.moneySmall
                              .copyWith(color: AppColors.citadelStoneDk)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sprite reutilizável (também usado no onboarding).
class CitadelSprite extends StatefulWidget {
  const CitadelSprite({super.key, this.size = 72});
  final double size;

  @override
  State<CitadelSprite> createState() => _CitadelSpriteState();
}

class _CitadelSpriteState extends State<CitadelSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _CitadelPainter(flag: _ctrl.value),
        ),
      ),
    );
  }
}

class _CitadelPainter extends CustomPainter {
  _CitadelPainter({required this.flag});
  final double flag; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 16;
    final s = size.width / grid;

    final stoneHi   = Paint()..color = AppColors.citadelStoneTone;
    final stone     = Paint()..color = AppColors.citadelStone;
    final stoneDk   = Paint()..color = AppColors.citadelStoneDk;
    final stoneDeep = Paint()..color = AppColors.citadelStoneDeep;
    final flagHi    = Paint()..color = AppColors.purpleTone;
    final flagMain  = Paint()..color = AppColors.royalPurple;
    final flagDk    = Paint()..color = AppColors.purpleDark;
    final pole      = Paint()..color = AppColors.ink;
    final gold      = Paint()..color = AppColors.goldCoin;
    final goldHi    = Paint()..color = AppColors.goldTone;
    final goldDk    = Paint()..color = AppColors.goldCoinDk;
    final ink       = Paint()..color = AppColors.ink;
    final win       = Paint()..color = AppColors.sunYellow;

    void px(int x, int y, Paint p) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);

    // 0 vazio | 1 stone | 2 stoneDk | 3 ink (contorno/portal) | 4 pole
    // 5 flagMain | 6 flagHi | 7 flagDk | 8 stoneHi | 9 stoneDeep
    // 10 gold | 11 goldHi | 12 goldDk | 13 window
    const map = <List<int>>[
      [0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0], // mastro
      [0,0,0,0,0,0,4,5,5,5,5,0,0,0,0,0],
      [0,0,0,0,0,0,4,5,6,6,5,7,0,0,0,0],
      [0,0,0,0,0,0,4,5,5,5,5,7,0,0,0,0],
      [0,0,0,3,0,3,4,5,5,5,0,0,0,3,0,3], // ameias topo
      [0,0,3,8,3,3,4,3,3,3,3,3,3,8,3,0],
      [0,0,3,8,1,1,1,11,10,11,1,1,1,8,3,0], // brasão dourado
      [0,3,8,1,1,2,1,10,10,10,1,2,1,1,8,3],
      [0,3,1,1,1,1,12,10,10,10,12,1,1,1,1,3],
      [0,3,1,2,1,13,1,10,10,10,1,13,1,2,1,3], // janelas
      [0,3,1,1,1,13,1,1,3,1,1,13,1,1,1,3],
      [0,3,1,1,2,1,1,3,3,3,1,1,2,1,1,3],
      [0,3,8,1,1,1,3,9,9,9,3,1,1,1,8,3],
      [0,3,8,1,2,1,3,9,3,9,3,1,2,1,8,3],
      [0,3,8,1,1,2,3,9,3,9,3,2,1,1,8,3], // portão
      [3,9,9,9,9,9,3,3,3,3,3,9,9,9,9,3], // base alargada
    ];

    // Onda da bandeira: desloca colunas conforme `flag`.
    final wave = (math.sin(flag * math.pi * 2) * 1.6).round().clamp(-2, 2);

    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        final v = map[y][x];
        if (v == 0) continue;

        // Aplica onda apenas nas células de bandeira (5, 6, 7).
        int dx = 0;
        if (v == 5 || v == 6 || v == 7) {
          dx = y == 2 ? wave : (y == 1 || y == 3 ? wave ~/ 2 : 0);
        }

        final px2 = x + dx;
        if (px2 < 0 || px2 >= grid) continue;

        switch (v) {
          case 1:  px(px2, y, stone);    break;
          case 2:  px(px2, y, stoneDk);  break;
          case 3:  px(px2, y, ink);      break;
          case 4:  px(px2, y, pole);     break;
          case 5:  px(px2, y, flagMain); break;
          case 6:  px(px2, y, flagHi);   break;
          case 7:  px(px2, y, flagDk);   break;
          case 8:  px(px2, y, stoneHi);  break;
          case 9:  px(px2, y, stoneDeep);break;
          case 10: px(px2, y, gold);     break;
          case 11: px(px2, y, goldHi);   break;
          case 12: px(px2, y, goldDk);   break;
          case 13: px(px2, y, win);      break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CitadelPainter old) => old.flag != flag;
}
