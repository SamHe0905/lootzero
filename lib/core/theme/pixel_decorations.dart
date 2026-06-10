import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Decorações "hard pixel": borda preta grossa, cantos quadrados,
/// sombra dura e — o pulo do gato — **bevel interno** com highlight
/// (lighten) no topo/esquerda e shadow (darken) no rodapé/direita.
/// Isso dá o efeito de bloco moldado em metal/pedra dos jogos 16-bit.
abstract class PixelDecorations {
  static const double borderWidth = 3.0;
  static const double bevelWidth = 3.0;

  /// Sombra dura (offset, blur 0).
  static List<BoxShadow> hardShadow(
          {Color color = AppColors.ink, double dx = 5, double dy = 5}) =>
      [
        BoxShadow(
          color: color,
          offset: Offset(dx, dy),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  /// Caixa "flat" simples (sem bevel) — útil pra badges pequenas.
  static BoxDecoration box({
    required Color fill,
    Color border = AppColors.ink,
    bool shadow = true,
    Color shadowColor = AppColors.ink,
  }) =>
      BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: borderWidth),
        borderRadius: BorderRadius.zero,
        boxShadow: shadow ? hardShadow(color: shadowColor) : null,
      );
}

/// Painter de bevel pixel-art completo.
/// Camadas (ordem de pintura):
///   1. Fundo (fill)
///   2. Highlight: 2-3px no topo + 2-3px na esquerda (cor mais clara)
///   3. Shadow:   2-3px no rodapé + 2-3px na direita (cor mais escura)
///   4. Borda preta externa
///   5. (opcional) sombra dura externa via BoxShadow do widget parent
class BevelPainter extends CustomPainter {
  BevelPainter({
    required this.fill,
    Color? highlight,
    Color? shadow,
    this.bevel = 3.0,
    this.border = 3.0,
    this.borderColor = AppColors.ink,
  })  : highlight = highlight ?? AppColors.lighten(fill),
        shadow = shadow ?? AppColors.darken(fill);

  final Color fill;
  final Color highlight;
  final Color shadow;
  final double bevel;
  final double border;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final w = size.width;
    final h = size.height;

    // 1) fundo
    p.color = fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), p);

    // 2) bevel highlight (topo + esquerda) — dentro da borda
    p.color = highlight;
    canvas.drawRect(Rect.fromLTWH(border, border, w - border * 2, bevel), p);
    canvas.drawRect(Rect.fromLTWH(border, border, bevel, h - border * 2), p);

    // 3) bevel shadow (rodapé + direita)
    p.color = shadow;
    canvas.drawRect(
        Rect.fromLTWH(border, h - border - bevel, w - border * 2, bevel), p);
    canvas.drawRect(
        Rect.fromLTWH(w - border - bevel, border, bevel, h - border * 2), p);

    // 4) borda preta externa
    p.color = borderColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, border), p);
    canvas.drawRect(Rect.fromLTWH(0, h - border, w, border), p);
    canvas.drawRect(Rect.fromLTWH(0, 0, border, h), p);
    canvas.drawRect(Rect.fromLTWH(w - border, 0, border, h), p);
  }

  @override
  bool shouldRepaint(covariant BevelPainter old) =>
      old.fill != fill ||
      old.highlight != highlight ||
      old.shadow != shadow ||
      old.bevel != bevel ||
      old.border != border;
}
