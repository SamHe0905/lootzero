/// Tipo de envelope/bloco no orçamento Base Zero.
enum EnvelopeKind {
  /// Fundo YOLO — Bloco de Interrogação. Gastos impulsivos.
  yolo,

  /// Contas fixas / categorias recorrentes (aluguel, comida, etc).
  bill,

  /// Reserva / poupança comum.
  savings,

  /// Vinculado à Grande Meta (Castelo do Bowser).
  goal,
}
