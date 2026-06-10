import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/pixel_container.dart';
import '../../../../core/widgets/pixel_progress_bar.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../domain/entities/envelope.dart';

class EnvelopeTile extends StatelessWidget {
  const EnvelopeTile({super.key, required this.envelope});
  final Envelope envelope;

  @override
  Widget build(BuildContext context) {
    final broke = envelope.isBroke;
    final near = envelope.progress > 0.8 && !broke;
    final barColor = broke
        ? AppColors.rubyRed
        : near
            ? AppColors.goldCoin
            : AppColors.emerald;

    final iconBg = broke
        ? AppColors.rubyDark
        : near
            ? AppColors.goldCoinDk
            : AppColors.emeraldDark;

    return PixelContainer(
      fill: AppColors.cloudWhite,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      shadowOffset: 4,
      child: Row(
        children: [
          // Ícone com bevel próprio (mini "bloco" colorido)
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: BevelPainter(fill: iconBg),
              child: Center(
                child: Icon(envelope.icon,
                    color: AppColors.cloudWhite, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(envelope.name.toUpperCase(),
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                PixelProgressBar(
                  value: envelope.progress,
                  fill: barColor,
                  height: 16,
                  segments: 14,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    money(envelope.available),
                    style: AppTextStyles.moneySmall.copyWith(
                      color: broke
                          ? AppColors.rubyRed
                          : AppColors.emeraldDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('de ${money(envelope.allocated)}',
                      style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
