/// Transação — pode vir do Open Finance (Inbox) ou ser manual.
class Transaction {
  final String id;
  final String description;
  final double amount; // negativo = saída, positivo = entrada
  final DateTime date;
  final String? envelopeId; // null = ainda no Portal de Entrada
  final String? merchant;

  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.envelopeId,
    this.merchant,
  });

  bool get isAssigned => envelopeId != null;
  bool get isInflow => amount > 0;

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? envelopeId,
    String? merchant,
    bool clearEnvelope = false,
  }) =>
      Transaction(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        envelopeId: clearEnvelope ? null : (envelopeId ?? this.envelopeId),
        merchant: merchant ?? this.merchant,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'envelopeId': envelopeId,
        'merchant': merchant,
      };

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as String,
        description: j['description'] as String,
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.parse(j['date'] as String),
        envelopeId: j['envelopeId'] as String?,
        merchant: j['merchant'] as String?,
      );
}
