import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/coin_sprite.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';

Future<void> showEditIncomeSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _EditIncomeSheet(),
  );
}

class _EditIncomeSheet extends ConsumerStatefulWidget {
  const _EditIncomeSheet();
  @override
  ConsumerState<_EditIncomeSheet> createState() => _EditIncomeSheetState();
}

class _EditIncomeSheetState extends ConsumerState<_EditIncomeSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final current = ref.read(appProvider).income;
    _ctrl = TextEditingController(text: current.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (v == null || v < 0) return;
    ref.read(appProvider.notifier).setIncome(v);
    HapticService.success();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald,
        content: Text('Receita atualizada pra ${money(v)}.',
            style: AppTextStyles.body
                .copyWith(color: AppColors.cloudWhite)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.parchment,
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: PixelDecorations.hardShadow(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CoinSprite(size: 28),
                const SizedBox(width: 10),
                Text('EDITAR RECEITA', style: AppTextStyles.cardTitle),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Quanto entra pra você nesse mês? Pode mudar a qualquer momento (freela, bônus, salário).',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 14),
            Text('VALOR (R\$)', style: AppTextStyles.badge),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cloudWhite,
                border: Border.all(color: AppColors.ink, width: 3),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _ctrl,
                style: AppTextStyles.money
                    .copyWith(color: AppColors.emeraldDark, fontSize: 32),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
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
                PixelButton(
                    label: 'SALVAR', icon: Icons.check, onPressed: _save),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
