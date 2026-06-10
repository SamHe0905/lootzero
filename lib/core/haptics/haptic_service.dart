import 'package:flutter/services.dart';

/// Punição tátil. Em déficit, dispara um padrão "pesado" de erro/Game Over.
abstract class HapticService {
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.heavyImpact();
  }

  static Future<void> coin() => HapticFeedback.selectionClick();

  static Future<void> success() => HapticFeedback.mediumImpact();
}
