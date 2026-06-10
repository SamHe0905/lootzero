import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Botão 16-bit com bevel pixel-art. Ao pressionar, "afunda" — a sombra
/// dura externa some e o conteúdo desce em sincronia.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fill = AppColors.emerald,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color fill;
  final IconData? icon;
  final EdgeInsets padding;
  final bool expand;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dy = _pressed ? 0.0 : 5.0;
    final core = CustomPaint(
      painter: BevelPainter(fill: widget.fill),
      child: Padding(
        padding: widget.padding,
        child: Row(
          mainAxisSize:
              widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: AppColors.cloudWhite, size: 16),
              const SizedBox(width: 10),
            ],
            Text(widget.label, style: AppTextStyles.button),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_pressed ? 5 : 0, _pressed ? 5 : 0, 0),
        decoration: BoxDecoration(
          boxShadow: PixelDecorations.hardShadow(dx: dy, dy: dy),
        ),
        child: core,
      ),
    );
  }
}
