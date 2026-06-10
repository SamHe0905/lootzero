import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/wildcard_chest_card.dart';

/// Sprite grande do baú para o onboarding — mostrado em estado "transbordando"
/// (fillRatio = 1.0) para impressionar o usuário na introdução.
class WildcardChestIntro extends StatelessWidget {
  const WildcardChestIntro({super.key});

  @override
  Widget build(BuildContext context) => const ChestSprite(
        broke: false,
        fillRatio: 1.0,
        size: 220,
      );
}
