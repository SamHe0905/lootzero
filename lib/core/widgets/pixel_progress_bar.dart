import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Barra de progresso segmentada — estilo "vida/poder" 16-bit.
/// Cada segmento tem **gradiente vertical** (claro em cima, escuro embaixo).
class PixelProgressBar extends StatelessWidget {
  const PixelProgressBar({
    super.key,
    required this.value, // 0.0 - 1.0
    this.fill = AppColors.emerald,
    this.height = 22,
    this.segments = 20,
    this.gap = 1.0,
  });

  final double value;
  final Color fill;
  final double height;
  final int segments;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final lit = (value.clamp(0.0, 1.0) * segments).round();
    final tone = AppColors.lighten(fill, 0.18);
    final deep = AppColors.darken(fill, 0.18);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.ink, width: 3),
        boxShadow: PixelDecorations.hardShadow(dx: 3, dy: 3),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: List.generate(segments, (i) {
          final isLit = i < lit;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: gap / 2),
              decoration: BoxDecoration(
                gradient: isLit
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [tone, fill, deep],
                        stops: const [0.0, 0.45, 1.0],
                      )
                    : null,
                color: isLit ? null : AppColors.inkLight,
              ),
            ),
          );
        }),
      ),
    );
  }
}
