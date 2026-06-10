import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../domain/entities/envelope.dart';
import '../../../domain/enums/envelope_type.dart';

/// Sheet de criar ou editar cofre.
/// Passa `envelopeId = null` pra criar; passa o id pra editar.
Future<void> showEnvelopeFormSheet(
  BuildContext context,
  WidgetRef ref, {
  String? envelopeId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _EnvelopeFormSheet(envelopeId: envelopeId),
  );
}

class _EnvelopeFormSheet extends ConsumerStatefulWidget {
  const _EnvelopeFormSheet({this.envelopeId});
  final String? envelopeId;

  @override
  ConsumerState<_EnvelopeFormSheet> createState() =>
      _EnvelopeFormSheetState();
}

class _EnvelopeFormSheetState
    extends ConsumerState<_EnvelopeFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _allocated;
  late IconData _icon;
  late EnvelopeKind _kind;
  Envelope? _existing;

  bool get _isEdit => widget.envelopeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _existing = ref.read(appProvider).envelopeById(widget.envelopeId!);
      _name = TextEditingController(text: _existing!.name);
      _allocated = TextEditingController(
          text: _existing!.allocated.toStringAsFixed(2));
      _icon = _existing!.icon;
      _kind = _existing!.kind;
    } else {
      _name = TextEditingController();
      _allocated = TextEditingController(text: '0');
      _icon = Icons.savings;
      _kind = EnvelopeKind.bill;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _allocated.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final picked = await showIconPicker(context, selected: _icon);
    if (picked != null) setState(() => _icon = picked);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.rubyRed,
        content: Text(msg,
            style: AppTextStyles.body
                .copyWith(color: AppColors.cloudWhite)),
      ),
    );
  }

  void _save() {
    final state = ref.read(appProvider);
    final name = _name.text.trim();
    if (name.isEmpty) {
      _showError('Dá um nome pro cofre.');
      return;
    }
    final allocated =
        double.tryParse(_allocated.text.replaceAll(',', '.')) ?? 0;
    if (allocated < 0) {
      _showError('Alocação não pode ser negativa.');
      return;
    }

    // Valida a pool.
    if (_isEdit) {
      final current = _existing!.allocated;
      final delta = allocated - current;
      if (delta > 0 && state.availableToAssign < delta) {
        _showError(
          'Falta R\$ ${(delta - state.availableToAssign).toStringAsFixed(2)} '
          'na pool "A ALOCAR" pra esse aumento.',
        );
        return;
      }
    } else if (allocated > 0 &&
        state.availableToAssign < allocated) {
      _showError(
        'Pool insuficiente. Você tem R\$ ${state.availableToAssign.toStringAsFixed(2)} '
        'a alocar. Aumenta a receita ou cria o cofre com R\$ 0.',
      );
      return;
    }

    final notifier = ref.read(appProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    if (_isEdit) {
      notifier.updateEnvelope(
        widget.envelopeId!,
        name: name,
        allocated: allocated,
        icon: _icon,
      );
    } else {
      final id =
          notifier.addEnvelope(name: name, kind: _kind, icon: _icon);
      if (allocated > 0) {
        notifier.addAllocation(envelopeId: id, amount: allocated);
      }
    }
    HapticService.success();
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald,
        content: Text(
          _isEdit
              ? 'Cofre "$name" atualizado.'
              : 'Cofre "$name" criado.',
          style: AppTextStyles.body
              .copyWith(color: AppColors.cloudWhite),
        ),
      ),
    );
  }

  void _delete() {
    if (!_isEdit) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.parchment,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('DELETAR COFRE?', style: AppTextStyles.cardTitle),
        content: Text(
          'As transações dele voltam pro Portal de Entrada.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('CANCELAR', style: AppTextStyles.badge),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(appProvider.notifier)
                  .deleteEnvelope(widget.envelopeId!);
              Navigator.pop(context);
              HapticService.error();
            },
            child: Text('DELETAR',
                style: AppTextStyles.badge
                    .copyWith(color: AppColors.rubyRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pool = ref.watch(appProvider).availableToAssign;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? 'EDITAR COFRE' : 'NOVO COFRE',
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 14),

              // Ícone (tap pra trocar)
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickIcon,
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldDark,
                        border: Border.all(color: AppColors.ink, width: 3),
                      ),
                      child: Icon(_icon,
                          color: AppColors.cloudWhite, size: 26),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _pickIcon,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cloudWhite,
                        border: Border.all(
                            color: AppColors.ink, width: 2),
                      ),
                      child: Text('TROCAR ÍCONE',
                          style: AppTextStyles.badge),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _Field(label: 'NOME', controller: _name, hint: 'Ex: Pet'),
              const SizedBox(height: 10),
              _Field(
                label: 'ALOCAÇÃO MENSAL (R\$)',
                controller: _allocated,
                keyboard:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 6),
                Text('A alocação vem da pool "A ALOCAR".',
                    style: AppTextStyles.caption),
                Text('Disponível: R\$ ${pool.toStringAsFixed(2)}',
                    style: AppTextStyles.caption.copyWith(
                        color: pool > 0
                            ? AppColors.emeraldDark
                            : AppColors.rubyRed)),
              ],
              const SizedBox(height: 10),

              // Tipo (yolo / fixo)
              Text('TIPO', style: AppTextStyles.badge),
              const SizedBox(height: 6),
              Row(
                children: [
                  _TypeChip(
                    label: 'COFRE COMUM',
                    selected: _kind == EnvelopeKind.bill,
                    onTap: () => setState(() => _kind = EnvelopeKind.bill),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'BAÚ CURINGA',
                    selected: _kind == EnvelopeKind.yolo,
                    onTap: () => setState(() => _kind = EnvelopeKind.yolo),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isEdit)
                    GestureDetector(
                      onTap: _delete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.rubyRed,
                          border:
                              Border.all(color: AppColors.ink, width: 3),
                          boxShadow:
                              PixelDecorations.hardShadow(dx: 3, dy: 3),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                color: AppColors.cloudWhite, size: 14),
                            const SizedBox(width: 6),
                            Text('DELETAR',
                                style: AppTextStyles.badge.copyWith(
                                    color: AppColors.cloudWhite)),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cloudWhite,
                            border: Border.all(
                                color: AppColors.ink, width: 2),
                          ),
                          child: Text('CANCELAR',
                              style: AppTextStyles.badge),
                        ),
                      ),
                      const SizedBox(width: 10),
                      PixelButton(
                          label: 'SALVAR',
                          icon: Icons.check,
                          onPressed: _save),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final String? hint;

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
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppTextStyles.body
                  .copyWith(color: AppColors.citadelStone),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald : AppColors.cloudWhite,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(label,
            style: AppTextStyles.badge.copyWith(
                color:
                    selected ? AppColors.cloudWhite : AppColors.ink)),
      ),
    );
  }
}
