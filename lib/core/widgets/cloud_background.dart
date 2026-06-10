import 'package:flutter/material.dart';
import 'parallax_sky.dart';

/// Compatibilidade — redireciona para `ParallaxSky`.
class CloudBackground extends StatelessWidget {
  const CloudBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ParallaxSky(showHills: true, child: child);
}
