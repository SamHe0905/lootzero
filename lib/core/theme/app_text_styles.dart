import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografia retro:
/// - 'Press Start 2P' — títulos/HUD (densa, pixelada).
/// - 'VT323' — corpo e números (legível, ainda pixelada).
abstract class AppTextStyles {
  static TextStyle _press(double size,
          {Color color = AppColors.ink,
          double height = 1.5,
          double spacing = 1.0}) =>
      GoogleFonts.pressStart2p(
          fontSize: size,
          color: color,
          height: height,
          letterSpacing: spacing);

  static TextStyle _vt(double size,
          {Color color = AppColors.ink,
          FontWeight w = FontWeight.normal,
          double height = 1.05,
          double spacing = 0}) =>
      GoogleFonts.vt323(
          fontSize: size,
          color: color,
          fontWeight: w,
          height: height,
          letterSpacing: spacing);

  // HUD / títulos pixelados
  static TextStyle get hudTitle =>
      _press(18, spacing: 2.0);
  static TextStyle get cardTitle =>
      _press(11, spacing: 1.4);
  static TextStyle get button =>
      _press(10, color: AppColors.cloudWhite, spacing: 1.2);
  static TextStyle get badge =>
      _press(8, spacing: 1.0);

  // Corpo / números (VT323 — legíveis e bonitos)
  static TextStyle get money =>
      _vt(40, w: FontWeight.bold, height: 1.0);
  static TextStyle get moneySmall =>
      _vt(26, height: 1.05);
  static TextStyle get body =>
      _vt(22, height: 1.15);
  static TextStyle get caption =>
      _vt(18, color: AppColors.citadelStoneDk, height: 1.1);
  static TextStyle get dialog =>
      _vt(24, height: 1.2);
}
