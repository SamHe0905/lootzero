import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final txs = state.assigned;

    return ParallaxSky(
      showHills: true,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: PixelContainer(
                  fill: AppColors.ink,
                  bevel: false,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.goldCoin,
                          border: Border.all(
                              color: AppColors.ink, width: 2),
                        ),
                        child: const Icon(Icons.history,
                            color: AppColors.ink, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HISTÓRICO',
                                style: AppTextStyles.cardTitle.copyWith(
                                    color: AppColors.cloudWhite)),
                            const SizedBox(height: 2),
                            Text(
                                '${txs.length} transação${txs.length == 1 ? "" : "ões"} catalogadas',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.cloudWhite
                                        .withOpacity(0.6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (txs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: PixelContainer(
                      fill: AppColors.parchment,
                      child: Text('Sem transações ainda.',
                          style: AppTextStyles.body),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final t = txs[i];
                    final env = state.envelopes
                        .where((e) => e.id == t.envelopeId)
                        .firstOrNull;
                    return Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: PixelContainer(
                        fill: AppColors.cloudWhite,
                        shadowOffset: 4,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.emeraldDark,
                                border: Border.all(
                                    color: AppColors.ink, width: 2),
                              ),
                              child: Icon(env?.icon ?? Icons.help,
                                  color: AppColors.cloudWhite, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(t.description,
                                      style: AppTextStyles.body,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                    '${env?.name ?? "—"} • ${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(money(t.amount),
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.rubyRed,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (i * 50).ms, duration: 240.ms)
                          .slideX(begin: 0.08, curve: Curves.easeOut),
                    );
                  },
                  childCount: txs.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}
