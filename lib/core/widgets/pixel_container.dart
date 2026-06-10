import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Container 16-bit com **bevel** (highlight no topo/esquerda + shadow no
/// rodapé/direita), borda preta e sombra dura externa.
/// É a peça visual base do app — todo card/painel/envelope passa por aqui.
class PixelContainer extends StatelessWidget {
  const PixelContainer({
    super.key,
    required this.child,
    this.fill = AppColors.parchment,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.shadow = true,
    this.shadowOffset = 5,
    this.bevel = true,
    this.highlight,
    this.shadowColor,
  });

  final Widget child;
  final Color fill;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool shadow;
  final double shadowOffset;
  final bool bevel;
  final Color? highlight;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final innerPainter = bevel
        ? BevelPainter(
            fill: fill,
            highlight: highlight,
            shadow: shadowColor,
          )
        : null;

    final content = Padding(padding: padding, child: child);

    final box = CustomPaint(
      painter: innerPainter,
      child: content,
    );

    final wrapper = Container(
      decoration: shadow
          ? BoxDecoration(
              boxShadow: PixelDecorations.hardShadow(
                  dx: shadowOffset, dy: shadowOffset),
            )
          : null,
      child: bevel
          ? box
          : DecoratedBox(
              decoration: PixelDecorations.box(
                  fill: fill, shadow: false),
              child: content,
            ),
    );

    if (onTap == null) return wrapper;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: wrapper,
    );
  }
}
