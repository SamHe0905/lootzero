import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/pixel_progress_bar.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import '../../transaction/presentation/add_transaction_sheet.dart';
import '../../transaction/presentation/add_allocation_sheet.dart';
import '../../envelope_manage/presentation/envelope_form_sheet.dart';

class EnvelopeDetailScreen extends ConsumerWidget {
  const EnvelopeDetailScreen({super.key, required this.envelopeId});
  final String envelopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final env = state.envelopeById(envelopeId);
    final txs = state.assigned.where((t) => t.envelopeId == envelopeId).toList();

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(env.name.toUpperCase()),
        backgroundColor: AppColors.ink.withOpacity(0.85),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar cofre',
            onPressed: () => showEnvelopeFormSheet(context, ref,
                envelopeId: env.id),
          ),
        ],
      ),
      body: ParallaxSky(
        showHills: true,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 12),
                  child: PixelContainer(
                    fill: AppColors.parchment,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: env.isBroke
                                    ? AppColors.rubyDark
                                    : AppColors.emeraldDark,
                                border: Border.all(
                                    color: AppColors.ink, width: 3),
                              ),
                              child: Icon(env.icon,
                                  color: AppColors.cloudWhite, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(env.name.toUpperCase(),
                                      style: AppTextStyles.cardTitle),
                                  const SizedBox(height: 4),
                                  Text('Cofre — alocação ZBB',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        PixelProgressBar(
                          value: env.progress,
                          fill: env.isBroke
                              ? AppColors.rubyRed
                              : AppColors.emerald,
                          height: 24,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DISPONÍVEL',
                                    style: AppTextStyles.badge),
                                Text(
                                  money(env.available),
                                  style: AppTextStyles.money.copyWith(
                                    color: env.isBroke
                                        ? AppColors.rubyRed
                                        : AppColors.emeraldDark,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('ALOCADO',
                                    style: AppTextStyles.badge),
                                Text(money(env.allocated),
                                    style: AppTextStyles.moneySmall),
                                const SizedBox(height: 6),
                                Text('GASTO',
                                    style: AppTextStyles.badge),
                                Text(money(env.spent),
                                    style: AppTextStyles.moneySmall),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              PixelButton(
                                label: 'REFORÇAR',
                                icon: Icons.arrow_downward,
                                fill: AppColors.emerald,
                                onPressed: () => showAddAllocationSheet(
                                    context, ref,
                                    envelopeId: env.id),
                              ),
                              PixelButton(
                                label: 'REGISTRAR GASTO',
                                icon: Icons.remove,
                                fill: AppColors.royalPurple,
                                onPressed: () => showAddTransactionSheet(
                                    context, ref,
                                    envelopeId: env.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 320.ms),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Text('TRANSAÇÕES',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.cloudWhite,
                        shadows: [
                          const Shadow(
                              offset: Offset(2, 2),
                              color: AppColors.ink,
                              blurRadius: 0),
                        ],
                      )),
                ),
              ),

              if (txs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PixelContainer(
                      fill: AppColors.cloudWhite,
                      child: Center(
                        child: Text('Nenhuma transação ainda.',
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
                      return Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: PixelContainer(
                          fill: AppColors.cloudWhite,
                          shadowOffset: 4,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(t.description,
                                        style: AppTextStyles.body),
                                    Text(
                                      '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Text(money(t.amount),
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.rubyRed,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ).animate().fadeIn(delay: (i * 50).ms),
                      );
                    },
                    childCount: txs.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }
}
