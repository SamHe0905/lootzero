import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/lz_logo.dart';
import '../../../core/widgets/mascot_zero.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import '../../citadel_detail/presentation/edit_citadel_sheet.dart';
import '../../income/presentation/edit_income_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);

    return ParallaxSky(
      showHills: true,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const LzLogo(size: 96),
              const SizedBox(height: 8),
              Text('LOOT ZERO',
                  style: AppTextStyles.hudTitle.copyWith(
                    color: AppColors.cloudWhite,
                    shadows: [
                      const Shadow(
                          offset: Offset(2, 2),
                          color: AppColors.ink,
                          blurRadius: 0),
                    ],
                  )),
              Text('v0.1.0',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.cloudWhite.withOpacity(0.7))),
              const SizedBox(height: 22),

              // ============ MEU ORÇAMENTO ============
              PixelContainer(
                fill: AppColors.parchment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MEU ORÇAMENTO',
                        style: AppTextStyles.cardTitle),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.attach_money,
                      label: 'Receita do mês',
                      trailing: money(state.income),
                      onTap: () => showEditIncomeSheet(context, ref),
                    ),
                    _SettingRow(
                      icon: Icons.castle,
                      label: 'Cidadela (meta)',
                      trailing: money(state.citadel.target),
                      onTap: () => showEditCitadelSheet(context, ref),
                    ),
                    _SettingRow(
                      icon: Icons.account_balance_wallet,
                      label: 'Gerenciar cofres',
                      trailing: '${state.envelopes.length} cofres',
                      onTap: () => context.push('/envelopes'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ============ INTEGRAÇÕES ============
              PixelContainer(
                fill: AppColors.parchment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INTEGRAÇÕES', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.account_balance,
                      label: 'Conectar banco (Open Finance)',
                      trailing: 'EM BREVE',
                      onTap: null,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 60.ms, duration: 320.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ============ ZERO ============
              PixelContainer(
                fill: AppColors.parchment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SOBRE O ZERO', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const MascotZero(size: 72, mood: ZeroMood.calm),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Eu sou o Zero, guardião do seu loot. Mantenho seu orçamento na linha.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 320.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ============ MANUTENÇÃO ============
              PixelContainer(
                fill: AppColors.parchment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MANUTENÇÃO', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 12),
                    Center(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          PixelButton(
                            label: 'VIRAR MÊS',
                            icon: Icons.event_repeat,
                            fill: AppColors.emerald,
                            onPressed: () {
                              _confirm(
                                context,
                                title: 'VIRAR O MÊS?',
                                body:
                                    'Vai zerar os gastos de cada cofre mantendo a alocação e o histórico.',
                                onConfirm: () {
                                  ref
                                      .read(appProvider.notifier)
                                      .closeMonth();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor:
                                              AppColors.emerald,
                                          content: Text(
                                              'Mês virado! Cofres prontos pra um novo ciclo.',
                                              style: AppTextStyles
                                                  .body
                                                  .copyWith(
                                                      color: AppColors
                                                          .cloudWhite))));
                                },
                              );
                            },
                          ),
                          PixelButton(
                            label: 'REVER ONBOARDING',
                            icon: Icons.replay,
                            fill: AppColors.royalPurple,
                            onPressed: () async {
                              await OnboardingSeen.reset();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text(
                                            'Recarregue o app pra ver o onboarding.',
                                            style: AppTextStyles.body
                                                .copyWith(
                                                    color: AppColors
                                                        .cloudWhite))));
                              }
                            },
                          ),
                          PixelButton(
                            label: 'RESETAR TUDO',
                            icon: Icons.warning,
                            fill: AppColors.rubyRed,
                            onPressed: () {
                              _confirm(
                                context,
                                title: 'RESETAR TUDO?',
                                body:
                                    'Apaga seus cofres, transações e Cidadela. Volta ao estado inicial. Não tem undo.',
                                onConfirm: () async {
                                  await ref
                                      .read(appProvider.notifier)
                                      .factoryReset();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            backgroundColor:
                                                AppColors.emerald,
                                            content: Text(
                                                'Tudo resetado.',
                                                style: AppTextStyles
                                                    .body
                                                    .copyWith(
                                                        color: AppColors
                                                            .cloudWhite))));
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 180.ms, duration: 320.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

void _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required VoidCallback onConfirm,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.parchment,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text(title, style: AppTextStyles.cardTitle),
      content: Text(body, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('CANCELAR', style: AppTextStyles.badge),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: Text('CONFIRMAR',
              style: AppTextStyles.badge
                  .copyWith(color: AppColors.rubyRed)),
        ),
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.skyBlue,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Icon(icon, color: AppColors.ink, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(label,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(trailing,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.emeraldDark)),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: AppColors.citadelStoneDk, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
