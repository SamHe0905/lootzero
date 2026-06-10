import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Cenário 16-bit completo: gradiente de céu, sol pixel, colinas distantes,
/// grama em primeiro plano e **nuvens animadas** deslizando lentamente.
///
/// Substitui o antigo `CloudBackground`.
class ParallaxSky extends StatefulWidget {
  const ParallaxSky({
    super.key,
    required this.child,
    this.showSun = true,
    this.showHills = true,
    this.showGrass = false,
  });

  final Widget child;
  final bool showSun;
  final bool showHills;
  final bool showGrass;

  @override
  State<ParallaxSky> createState() => _ParallaxSkyState();
}

class _ParallaxSkyState extends State<ParallaxSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradiente de céu
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.skyTop, AppColors.skyBlue, AppColors.skyDeep],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // Sol + nuvens + colinas (anima)
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _SkyPainter(
              t: _ctrl.value,
              showSun: widget.showSun,
              showHills: widget.showHills,
              showGrass: widget.showGrass,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({
    required this.t,
    required this.showSun,
    required this.showHills,
    required this.showGrass,
  });

  final double t;
  final bool showSun;
  final bool showHills;
  final bool showGrass;

  @override
  void paint(Canvas canvas, Size size) {
    if (showSun) _paintSun(canvas, size);
    _paintClouds(canvas, size);
    if (showHills) _paintHills(canvas, size);
    if (showGrass) _paintGrass(canvas, size);
  }

  void _paintSun(Canvas canvas, Size size) {
    final cx = size.width * 0.82;
    final cy = size.height * 0.14;
    final s = 6.0;
    final core = Paint()..color = AppColors.sunCore;
    final glow = Paint()..color = AppColors.sunYellow.withOpacity(0.55);

    // Halo
    canvas.drawCircle(Offset(cx, cy), 38, glow);
    canvas.drawCircle(Offset(cx, cy), 28, Paint()..color = AppColors.sunYellow);

    // Núcleo pixelado (5x5)
    for (var y = -2; y <= 2; y++) {
      for (var x = -2; x <= 2; x++) {
        if (x * x + y * y > 5) continue;
        canvas.drawRect(
          Rect.fromLTWH(cx + x * s - s / 2, cy + y * s - s / 2, s, s),
          core,
        );
      }
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final cloud = Paint()..color = AppColors.cloudWhite;
    final shade = Paint()..color = AppColors.cloudShade;

    void pixelCloud(double x, double y, double sc) {
      final blocks = <Offset>[
        const Offset(0, 1), const Offset(1, 1), const Offset(2, 1),
        const Offset(3, 1), const Offset(4, 1), const Offset(5, 1),
        const Offset(1, 0), const Offset(2, 0), const Offset(3, 0),
        const Offset(4, 0), const Offset(0, 2), const Offset(1, 2),
        const Offset(2, 2), const Offset(3, 2), const Offset(4, 2),
        const Offset(5, 2),
      ];
      for (final b in blocks) {
        canvas.drawRect(
            Rect.fromLTWH(x + b.dx * sc, y + b.dy * sc, sc, sc), cloud);
      }
      // sombra inferior
      canvas.drawRect(
          Rect.fromLTWH(x, y + 2.5 * sc, 6 * sc, sc * 0.4), shade);
    }

    // Nuvem 1
    final off1 = (t * size.width * 0.7) % (size.width + 200) - 100;
    pixelCloud(off1, size.height * 0.10, 8);

    // Nuvem 2 (sentido oposto, ritmo diferente)
    final off2 =
        (size.width - (t * size.width * 0.5)) % (size.width + 200) - 100;
    pixelCloud(off2, size.height * 0.22, 10);

    // Nuvem 3
    final off3 = ((t + 0.4) * size.width * 0.6) % (size.width + 200) - 100;
    pixelCloud(off3, size.height * 0.32, 7);
  }

  void _paintHills(Canvas canvas, Size size) {
    final far = Paint()..color = AppColors.hillFar;
    final near = Paint()..color = AppColors.hillNear;
    final hillsTop = size.height * 0.58;

    // Colinas distantes — forma "pixel hill" (silhueta)
    final pathFar = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, hillsTop + 30)
      ..lineTo(size.width * 0.10, hillsTop + 30)
      ..lineTo(size.width * 0.15, hillsTop + 6)
      ..lineTo(size.width * 0.20, hillsTop + 30)
      ..lineTo(size.width * 0.35, hillsTop + 30)
      ..lineTo(size.width * 0.42, hillsTop)
      ..lineTo(size.width * 0.50, hillsTop + 30)
      ..lineTo(size.width * 0.62, hillsTop + 30)
      ..lineTo(size.width * 0.70, hillsTop + 12)
      ..lineTo(size.width * 0.78, hillsTop + 30)
      ..lineTo(size.width * 0.90, hillsTop + 30)
      ..lineTo(size.width * 0.95, hillsTop + 8)
      ..lineTo(size.width, hillsTop + 30)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(pathFar, far);

    // Colinas próximas — abaixo
    final nearTop = hillsTop + 48;
    final pathNear = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, nearTop + 14)
      ..lineTo(size.width * 0.12, nearTop)
      ..lineTo(size.width * 0.28, nearTop + 14)
      ..lineTo(size.width * 0.45, nearTop)
      ..lineTo(size.width * 0.62, nearTop + 14)
      ..lineTo(size.width * 0.80, nearTop)
      ..lineTo(size.width, nearTop + 14)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(pathNear, near);
  }

  void _paintGrass(Canvas canvas, Size size) {
    final grass = Paint()..color = AppColors.grass;
    final dk = Paint()..color = AppColors.grassDark;
    final grassH = 38.0;
    canvas.drawRect(
        Rect.fromLTWH(0, size.height - grassH, size.width, grassH), grass);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height - 6, size.width, 6), dk);
    // Tufos
    final tuft = Paint()..color = AppColors.grassTone;
    for (var i = 0; i < size.width; i += 24) {
      final h = 5.0 + math.Random(i).nextInt(5);
      canvas.drawRect(
          Rect.fromLTWH(i.toDouble(), size.height - grassH - h, 4, h), tuft);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.t != t;
}
