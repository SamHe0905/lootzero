import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Catálogo curado de ícones pra cofres. Cada categoria tem opções
/// que cobrem casos comuns de orçamento pessoal.
const _envelopeIcons = <IconData>[
  // Casa / contas
  Icons.home, Icons.bolt, Icons.water_drop, Icons.wifi, Icons.local_fire_department,
  // Comida
  Icons.restaurant, Icons.local_pizza, Icons.local_cafe, Icons.local_grocery_store,
  Icons.local_bar,
  // Transporte
  Icons.directions_bus, Icons.directions_car, Icons.local_gas_station,
  Icons.local_taxi, Icons.train, Icons.directions_bike,
  // Lazer / entretenimento
  Icons.sports_esports, Icons.movie, Icons.music_note, Icons.book, Icons.theater_comedy,
  Icons.beach_access, Icons.flight,
  // Saúde / bem-estar
  Icons.favorite, Icons.medical_services, Icons.fitness_center, Icons.spa,
  Icons.local_hospital, Icons.psychology,
  // Pessoas / pets / presentes
  Icons.pets, Icons.child_care, Icons.cake, Icons.card_giftcard, Icons.celebration,
  // Educação / trabalho
  Icons.school, Icons.work, Icons.computer, Icons.menu_book,
  // Moda / cuidados
  Icons.checkroom, Icons.face_retouching_natural, Icons.content_cut,
  // Misc
  Icons.savings, Icons.shopping_bag, Icons.smartphone, Icons.subscriptions,
  Icons.attach_money, Icons.help_outline, Icons.star,
];

/// Sheet pra escolher um ícone. Retorna o `IconData` selecionado.
Future<IconData?> showIconPicker(BuildContext context,
    {IconData? selected}) {
  return showModalBottomSheet<IconData>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _IconPickerSheet(selected: selected),
  );
}

class _IconPickerSheet extends StatelessWidget {
  const _IconPickerSheet({this.selected});
  final IconData? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
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
            Text('ESCOLHA UM ÍCONE',
                style: AppTextStyles.cardTitle),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.count(
                crossAxisCount: 6,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                shrinkWrap: true,
                children: _envelopeIcons.map((icon) {
                  final isSelected = selected?.codePoint == icon.codePoint;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.emerald
                            : AppColors.cloudWhite,
                        border:
                            Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.cloudWhite
                            : AppColors.ink,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
