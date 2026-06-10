import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import 'envelope_form_sheet.dart';

class ManageEnvelopesScreen extends ConsumerWidget {
  const ManageEnvelopesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MEUS COFRES'),
        backgroundColor: AppColors.ink.withOpacity(0.85),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
                    fill: AppColors.ink,
                    bevel: false,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.envelopes.length} cofres',
                                style: AppTextStyles.cardTitle.copyWith(
                                    color: AppColors.cloudWhite),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Alocado: ${money(state.allocatedTotal)} · A alocar: ${money(state.availableToAssign)}',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.cloudWhite
                                        .withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final env = state.envelopes[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: GestureDetector(
                        onTap: () => showEnvelopeFormSheet(context, ref,
                            envelopeId: env.id),
                        child: PixelContainer(
                          fill: AppColors.cloudWhite,
                          shadowOffset: 4,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldDark,
                                  border: Border.all(
                                      color: AppColors.ink, width: 2),
                                ),
                                child: Icon(env.icon,
                                    color: AppColors.cloudWhite, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(env.name.toUpperCase(),
                                        style: AppTextStyles.cardTitle
                                            .copyWith(fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Alocado: ${money(env.allocated)}',
                                        style: AppTextStyles.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.citadelStoneDk),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (i * 50).ms, duration: 240.ms)
                          .slideX(begin: 0.08, curve: Curves.easeOut),
                    );
                  },
                  childCount: state.envelopes.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Center(
                    child: PixelButton(
                      label: 'NOVO COFRE',
                      icon: Icons.add,
                      fill: AppColors.royalPurple,
                      onPressed: () =>
                          showEnvelopeFormSheet(context, ref),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
