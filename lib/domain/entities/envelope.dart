import 'package:flutter/material.dart';
import '../enums/envelope_type.dart';

/// Envelope/Cofre — categoria do orçamento Base Zero.
class Envelope {
  final String id;
  final String name;
  final double allocated;
  final double spent;
  final EnvelopeKind kind;
  final IconData icon;

  const Envelope({
    required this.id,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.kind,
    required this.icon,
  });

  double get available => allocated - spent;

  /// Cofre estourado: tinha alocação e furou. Cofre recém-criado (alloc=0)
  /// não é "broke" — é apenas vazio, aguardando reforço.
  bool get isBroke => allocated > 0 && available <= 0;

  /// Cofre vazio (sem alocação ainda). Usar pra mostrar "configure".
  bool get isEmpty => allocated == 0;

  double get progress =>
      allocated == 0 ? 0 : (spent / allocated).clamp(0, 1).toDouble();

  Envelope copyWith({
    String? id,
    String? name,
    double? allocated,
    double? spent,
    EnvelopeKind? kind,
    IconData? icon,
  }) =>
      Envelope(
        id: id ?? this.id,
        name: name ?? this.name,
        allocated: allocated ?? this.allocated,
        spent: spent ?? this.spent,
        kind: kind ?? this.kind,
        icon: icon ?? this.icon,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'allocated': allocated,
        'spent': spent,
        'kind': kind.name,
        'iconCp': icon.codePoint,
        'iconFf': icon.fontFamily,
      };

  factory Envelope.fromJson(Map<String, dynamic> j) => Envelope(
        id: j['id'] as String,
        name: j['name'] as String,
        allocated: (j['allocated'] as num).toDouble(),
        spent: (j['spent'] as num).toDouble(),
        kind: EnvelopeKind.values.byName(j['kind'] as String),
        icon: IconData(
          j['iconCp'] as int,
          fontFamily: j['iconFf'] as String? ?? 'MaterialIcons',
        ),
      );
}
