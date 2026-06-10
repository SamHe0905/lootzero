import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'pixel_container.dart';
import 'mascot_zero.dart';

/// Balão de fala do mascote **Zero** — usado no Real Talk
/// (alerta de déficit, lembretes de meta, etc.).
class MascotBalloon extends StatelessWidget {
  const MascotBalloon({
    super.key,
    required this.message,
    this.mood = ZeroMood.angry,
  });

  final String message;
  final ZeroMood mood;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MascotZero(size: 56, mood: mood),
        const SizedBox(width: 8),
        Expanded(
          child: PixelContainer(
            fill: AppColors.cloudWhite,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ZERO DIZ:', style: AppTextStyles.badge),
                const SizedBox(height: 6),
                Text(message, style: AppTextStyles.dialog),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
