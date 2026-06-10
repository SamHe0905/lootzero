import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/pixel_progress_bar.dart';
import '../../../core/widgets/coin_sprite.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import '../../dashboard/presentation/widgets/citadel_card.dart';
import 'edit_citadel_sheet.dart';

class CitadelDetailScreen extends ConsumerStatefulWidget {
  const CitadelDetailScreen({super.key});

  @override
  ConsumerState<CitadelDetailScreen> createState() =>
      _CitadelDetailScreenState();
}

class _CitadelDetailScreenState
    extends ConsumerState<CitadelDetailScreen> {
  double _deposit = 100;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final goal = state.citadel;
    final pct = (goal.progress * 100).round();
    final daysBehind = goal.daysBehind(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('A CIDADELA'),
        backgroundColor: AppColors.ink.withOpacity(0.85),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar meta',
            onPressed: () => showEditCitadelSheet(context, ref),
          ),
        ],
      ),
      body: ParallaxSky(
        showHills: true,
        showGrass: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
            child: Column(
              children: [
                const CitadelSprite(size: 140)
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: -0.2, curve: Curves.easeOutBack),
                const SizedBox(height: 12),

                PixelContainer(
                  fill: AppColors.parchment,
                  child: Column(
                    children: [
                      Text('PROGRESSO', style: AppTextStyles.badge),
                      const SizedBox(height: 4),
                      Text('$pct%',
                          style: AppTextStyles.money.copyWith(
                              color: AppColors.emeraldDark, fontSize: 60)),
                      const SizedBox(height: 8),
                      PixelProgressBar(
                          value: goal.progress, fill: AppColors.emerald),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GUARDADO',
                                  style: AppTextStyles.badge),
                              const SizedBox(height: 2),
                              Text(money(goal.saved),
                                  style: AppTextStyles.moneySmall.copyWith(
                                    color: AppColors.emeraldDark,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('META',
                                  style: AppTextStyles.badge),
                              const SizedBox(height: 2),
                              Text(money(goal.target),
                                  style: AppTextStyles.moneySmall),
                            ],
                          ),
                        ],
                      ),
                      if (daysBehind > 0) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.rubyRed,
                            border:
                                Border.all(color: AppColors.ink, width: 3),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning,
                                  color: AppColors.cloudWhite),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Atrasado em $daysBehind dias',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.cloudWhite),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 320.ms),

                const SizedBox(height: 16),

                PixelContainer(
                  fill: AppColors.cloudWhite,
                  child: Column(
                    children: [
                      Text('ENVIAR REFORÇO',
                          style: AppTextStyles.cardTitle),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CoinSprite(size: 40),
                          const SizedBox(width: 10),
                          Text(money(_deposit),
                              style: AppTextStyles.money.copyWith(
                                  color: AppColors.goldCoinDk,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: _deposit,
                        min: 50,
                        max: 2000,
                        divisions: 39,
                        activeColor: AppColors.emerald,
                        inactiveColor: AppColors.citadelStone,
                        onChanged: (v) => setState(() => _deposit = v),
                      ),
                      const SizedBox(height: 8),
                      PixelButton(
                        label: 'DEPOSITAR',
                        icon: Icons.send,
                        onPressed: () {
                          ref
                              .read(appProvider.notifier)
                              .depositToCitadel(_deposit);
                          HapticService.success();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.emerald,
                              content: Text(
                                  'Reforço de ${money(_deposit)} enviado!',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.cloudWhite)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 320.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
