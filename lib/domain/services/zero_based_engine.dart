import '../entities/envelope.dart';

/// Motor do Orçamento Base Zero (ZBB).
/// Regra de ouro: **todo centavo ganha um trabalho**.
/// `receita - Σ alocado` deve sempre tender a zero.
abstract class ZeroBasedEngine {
  /// Sobra de moedas "sem trabalho" — deve ser zero para o orçamento estar ok.
  static double availableToAssign({
    required double income,
    required List<Envelope> envelopes,
  }) {
    final allocated =
        envelopes.fold<double>(0, (sum, e) => sum + e.allocated);
    return income - allocated;
  }

  static bool isBalanced({
    required double income,
    required List<Envelope> envelopes,
  }) =>
      availableToAssign(income: income, envelopes: envelopes).abs() < 0.01;

  /// Soma de envelopes em déficit (gasto > alocado).
  static double totalOverspent(List<Envelope> envelopes) => envelopes
      .where((e) => e.available < 0)
      .fold<double>(0, (sum, e) => sum + e.available.abs());
}
