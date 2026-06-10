import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../domain/entities/citadel_goal.dart';

Future<void> showEditCitadelSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _EditCitadelSheet(),
  );
}

class _EditCitadelSheet extends ConsumerStatefulWidget {
  const _EditCitadelSheet();
  @override
  ConsumerState<_EditCitadelSheet> createState() =>
      _EditCitadelSheetState();
}

class _EditCitadelSheetState extends ConsumerState<_EditCitadelSheet> {
  late final TextEditingController _target;
  late final TextEditingController _saved;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    final g = ref.read(appProvider).citadel;
    _target = TextEditingController(text: g.target.toStringAsFixed(2));
    _saved = TextEditingController(text: g.saved.toStringAsFixed(2));
    _deadline = g.deadline;
  }

  @override
  void dispose() {
    _target.dispose();
    _saved.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    final t = double.tryParse(_target.text.replaceAll(',', '.'));
    final s = double.tryParse(_saved.text.replaceAll(',', '.'));
    if (t == null || t <= 0 || s == null || s < 0) return;

    ref.read(appProvider.notifier).setCitadel(
          CitadelGoal(target: t, saved: s, deadline: _deadline),
        );
    HapticService.success();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald,
        content: Text('Cidadela atualizada.',
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
            Text('EDITAR CIDADELA', style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text('Sua grande meta.', style: AppTextStyles.caption),
            const SizedBox(height: 14),

            _Field(
              label: 'META (R\$)',
              controller: _target,
              keyboard:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            _Field(
              label: 'JÁ GUARDADO (R\$)',
              controller: _saved,
              keyboard:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            Text('PRAZO', style: AppTextStyles.badge),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cloudWhite,
                  border: Border.all(color: AppColors.ink, width: 3),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    const SizedBox(width: 10),
                    Text(
                      '${_deadline.day.toString().padLeft(2, '0')}/'
                      '${_deadline.month.toString().padLeft(2, '0')}/'
                      '${_deadline.year}',
                      style: AppTextStyles.body,
                    ),
                  ],
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.badge),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cloudWhite,
            border: Border.all(color: AppColors.ink, width: 3),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: AppTextStyles.body,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
