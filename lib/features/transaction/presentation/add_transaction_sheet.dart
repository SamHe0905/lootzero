import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../data/repositories/app_repository.dart';

Future<void> showAddTransactionSheet(
  BuildContext context,
  WidgetRef ref, {
  required String envelopeId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AddTxSheet(envelopeId: envelopeId),
  );
}

class _AddTxSheet extends ConsumerStatefulWidget {
  const _AddTxSheet({required this.envelopeId});
  final String envelopeId;

  @override
  ConsumerState<_AddTxSheet> createState() => _AddTxSheetState();
}

class _AddTxSheetState extends ConsumerState<_AddTxSheet> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _desc.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (value == null || value <= 0 || _desc.text.trim().isEmpty) return;
    ref.read(appProvider.notifier).addManualTransaction(
          description: _desc.text.trim(),
          amount: value,
          envelopeId: widget.envelopeId,
        );
    HapticService.success();
    Navigator.pop(context);
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
        decoration: PixelDecorations.box(fill: AppColors.parchment),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NOVO GASTO', style: AppTextStyles.cardTitle),
            const SizedBox(height: 12),
            _PixelField(
              controller: _desc,
              label: 'Descrição',
              hint: 'Ex: Mercado',
            ),
            const SizedBox(height: 10),
            _PixelField(
              controller: _amount,
              label: 'Valor (R\$)',
              hint: '0,00',
              keyboard:
                  const TextInputType.numberWithOptions(decimal: true),
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
                    decoration: PixelDecorations.box(
                        fill: AppColors.cloudWhite),
                    child: Text('CANCELAR', style: AppTextStyles.badge),
                  ),
                ),
                const SizedBox(width: 12),
                PixelButton(
                  label: 'SALVAR',
                  icon: Icons.check,
                  onPressed: _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelField extends StatelessWidget {
  const _PixelField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboard,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.badge),
        const SizedBox(height: 6),
        Container(
          decoration: PixelDecorations.box(
              fill: AppColors.cloudWhite, shadow: false),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle:
                  AppTextStyles.body.copyWith(color: AppColors.citadelStone),
            ),
          ),
        ),
      ],
    );
  }
}
