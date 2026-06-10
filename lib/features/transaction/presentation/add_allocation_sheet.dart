import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/coin_sprite.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';

/// Sheet de "Reforçar Cofre" — puxa moedas do "A ALOCAR" pro envelope.
Future<void> showAddAllocationSheet(
  BuildContext context,
  WidgetRef ref, {
  required String envelopeId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AddAllocationSheet(envelopeId: envelopeId),
  );
}

class _AddAllocationSheet extends ConsumerStatefulWidget {
  const _AddAllocationSheet({required this.envelopeId});
  final String envelopeId;

  @override
  ConsumerState<_AddAllocationSheet> createState() =>
      _AddAllocationSheetState();
}

class _AddAllocationSheetState
    extends ConsumerState<_AddAllocationSheet> {
  double _amount = 50;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final pool = state.availableToAssign;
    final env = state.envelopeById(widget.envelopeId);
    final canSubmit = pool >= _amount && _amount > 0;

    // Slider max = quanto sobra na pool (ou pelo menos 50 pra UI não quebrar)
    final maxSlider = pool < 50 ? 50.0 : pool;
    if (_amount > maxSlider) _amount = maxSlider;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: PixelContainer(
        fill: AppColors.parchment,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldDark,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Icon(env.icon,
                      color: AppColors.cloudWhite, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REFORÇAR ${env.name.toUpperCase()}',
                          style: AppTextStyles.cardTitle),
                      Text('Mover moedas de "A ALOCAR" pro cofre',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pool disponível
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.ink,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Row(
                children: [
                  const CoinSprite(size: 24),
                  const SizedBox(width: 10),
                  Text('A ALOCAR:',
                      style: AppTextStyles.badge
                          .copyWith(color: AppColors.cloudWhite)),
                  const Spacer(),
                  Text(money(pool),
                      style: AppTextStyles.body.copyWith(
                        color: pool > 0
                            ? AppColors.goldTone
                            : AppColors.rubyTone,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Valor a reforçar
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CoinSprite(size: 32),
                  const SizedBox(width: 10),
                  Text(money(_amount),
                      style: AppTextStyles.money.copyWith(
                        color: canSubmit
                            ? AppColors.emeraldDark
                            : AppColors.rubyRed,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 4),
            Slider(
              value: _amount,
              min: 10,
              max: maxSlider,
              divisions: ((maxSlider - 10) / 10).clamp(1, 200).toInt(),
              activeColor: AppColors.emerald,
              inactiveColor: AppColors.citadelStone,
              onChanged: pool < 10
                  ? null
                  : (v) => setState(() => _amount = v),
            ),

            if (!canSubmit && pool < 10)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.rubyRed,
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning,
                        color: AppColors.cloudWhite, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sem moedas a alocar. Aumente a receita ou retire de outro cofre.',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.cloudWhite),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cloudWhite,
                      border:
                          Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: Text('CANCELAR', style: AppTextStyles.badge),
                  ),
                ),
                const SizedBox(width: 12),
                Opacity(
                  opacity: canSubmit ? 1.0 : 0.45,
                  child: IgnorePointer(
                    ignoring: !canSubmit,
                    child: PixelButton(
                      label: 'REFORÇAR',
                      icon: Icons.add,
                      onPressed: () {
                        final ok = ref
                            .read(appProvider.notifier)
                            .addAllocation(
                                envelopeId: widget.envelopeId,
                                amount: _amount);
                        if (ok) {
                          HapticService.success();
                          final messenger =
                              ScaffoldMessenger.of(context);
                          Navigator.pop(context);
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.emerald,
                              content: Text(
                                  '${money(_amount)} reforçados em ${env.name}!',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.cloudWhite)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
