import 'package:flutter/material.dart';

/// Paleta Loot Zero — 16-bit RPG.
/// Cada cor de marca tem variantes: tone (claro), main, dark, deep (sombra forte).
/// Isso permite bevel real (highlight + shadow) em todo componente.
abstract class AppColors {
  // ============ CÉU ============
  static const Color skyTop      = Color(0xFF7BAAFF); // topo (mais claro)
  static const Color skyBlue     = Color(0xFF5C94FC); // padrão
  static const Color skyDeep     = Color(0xFF3A6FE0); // horizonte
  static const Color sunYellow   = Color(0xFFFFE066);
  static const Color sunCore     = Color(0xFFFFB800);

  static const Color cloudWhite  = Color(0xFFFFFFFF);
  static const Color cloudShade  = Color(0xFFD6E4FF);

  // ============ GRAMA / TERRENO ============
  static const Color grassTone   = Color(0xFF3FD171);
  static const Color grass       = Color(0xFF1FB55C);
  static const Color grassDark   = Color(0xFF0D7A38);
  static const Color hillFar     = Color(0xFF6BA48A);
  static const Color hillNear    = Color(0xFF4F8C6E);

  // ============ ESMERALDA (sucesso) ============
  static const Color emeraldTone = Color(0xFF4ED98A);
  static const Color emerald     = Color(0xFF1FB55C);
  static const Color emeraldDark = Color(0xFF0D7A38);
  static const Color emeraldDeep = Color(0xFF064D22);

  // ============ OURO (saldo/moedas) ============
  static const Color goldTone    = Color(0xFFFFE066);
  static const Color goldCoin    = Color(0xFFFAC000);
  static const Color goldCoinDk  = Color(0xFFC89000);
  static const Color goldDeep    = Color(0xFF7A5800);

  // ============ RUBI (déficit/alerta) ============
  static const Color rubyTone    = Color(0xFFFF6A5C);
  static const Color rubyRed     = Color(0xFFE52521);
  static const Color rubyDark    = Color(0xFFA8160F);
  static const Color rubyDeep    = Color(0xFF560805);

  // ============ ROXO REAL (acento/mascote) ============
  static const Color purpleTone  = Color(0xFF9C6EE0);
  static const Color royalPurple = Color(0xFF6E3FB8);
  static const Color purpleDark  = Color(0xFF3F1F7A);
  static const Color purpleDeep  = Color(0xFF1F0A48);

  // ============ MATERIAIS (cidadela/baú) ============
  static const Color citadelStoneTone = Color(0xFFA8B0CC);
  static const Color citadelStone     = Color(0xFF8088A8);
  static const Color citadelStoneDk   = Color(0xFF4A506A);
  static const Color citadelStoneDeep = Color(0xFF2A2E40);

  static const Color chestGold      = Color(0xFFF8B800);
  static const Color chestGoldTone  = Color(0xFFFFD23F);
  static const Color chestWood      = Color(0xFF8B5A2B);
  static const Color chestWoodDk    = Color(0xFF5A3A1A);
  static const Color brokenStone    = Color(0xFFB05030);

  // ============ NEUTROS / HUD ============
  static const Color ink             = Color(0xFF1A1A1A);
  static const Color inkLight        = Color(0xFF3A3A3A);
  static const Color parchment       = Color(0xFFFCEFCB);
  static const Color parchmentTone   = Color(0xFFFFF7E0);
  static const Color parchmentShade  = Color(0xFFE8D9A8);
  static const Color overworldBg     = Color(0xFF5C94FC);

  /// Helper: derivar tom mais claro (highlight) e mais escuro (shadow) de uma cor.
  static Color lighten(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color darken(Color c, [double amount = 0.22]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
