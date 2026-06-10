import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/citadel_goal.dart';
import '../../domain/enums/envelope_type.dart';
import '../local/local_store.dart';

/// Estado global do app (única fonte da verdade).
class AppState {
  final CitadelGoal citadel;
  final List<Envelope> envelopes;
  final List<Transaction> transactions;
  final double income;

  const AppState({
    required this.citadel,
    required this.envelopes,
    required this.transactions,
    required this.income,
  });

  List<Transaction> get inbox =>
      transactions.where((t) => !t.isAssigned && !t.isInflow).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<Transaction> get assigned =>
      transactions.where((t) => t.isAssigned).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double get allocatedTotal =>
      envelopes.fold(0, (s, e) => s + e.allocated);

  /// Moedas sem trabalho — receita - tudo já alocado.
  double get availableToAssign => income - allocatedTotal;

  Envelope envelopeById(String id) =>
      envelopes.firstWhere((e) => e.id == id);

  AppState copyWith({
    CitadelGoal? citadel,
    List<Envelope>? envelopes,
    List<Transaction>? transactions,
    double? income,
  }) =>
      AppState(
        citadel: citadel ?? this.citadel,
        envelopes: envelopes ?? this.envelopes,
        transactions: transactions ?? this.transactions,
        income: income ?? this.income,
      );

  Map<String, dynamic> toJson() => {
        'version': 1,
        'income': income,
        'citadel': citadel.toJson(),
        'envelopes': envelopes.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory AppState.fromJson(Map<String, dynamic> j) => AppState(
        income: (j['income'] as num).toDouble(),
        citadel: CitadelGoal.fromJson(j['citadel'] as Map<String, dynamic>),
        envelopes: (j['envelopes'] as List)
            .map((e) => Envelope.fromJson(e as Map<String, dynamic>))
            .toList(),
        transactions: (j['transactions'] as List)
            .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

/// Controller central. Persiste em SharedPreferences via [LocalStore].
class AppController extends StateNotifier<AppState> {
  AppController({LocalStore? store})
      : _store = store ?? LocalStore(),
        super(_seed()) {
    _init();
  }

  final LocalStore _store;
  bool _loaded = false;

  /// Carrega do disco no boot. Se não tiver nada salvo, persiste o seed.
  Future<void> _init() async {
    final loaded = await _store.load();
    if (loaded != null) {
      state = loaded;
    } else {
      await _store.save(state);
    }
    _loaded = true;
  }

  /// Fire-and-forget: salva o estado atual após cada mutação.
  void _persist() {
    if (!_loaded) return; // evita sobrescrever o seed antes do load terminar
    _store.save(state);
  }

  // ============================================================
  // MUTAÇÕES (todas chamam _persist no final)
  // ============================================================

  void assignTransaction(String txId, String envelopeId) {
    final tx = state.transactions.firstWhere((t) => t.id == txId);
    final updatedTx = state.transactions.map((t) {
      if (t.id != txId) return t;
      return t.copyWith(envelopeId: envelopeId);
    }).toList();
    final updatedEnv = state.envelopes.map((e) {
      if (e.id != envelopeId) return e;
      return e.copyWith(spent: e.spent + tx.amount.abs());
    }).toList();
    state = state.copyWith(transactions: updatedTx, envelopes: updatedEnv);
    _persist();
  }

  void addManualTransaction({
    required String description,
    required double amount,
    required String envelopeId,
  }) {
    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      amount: -amount.abs(),
      date: DateTime.now(),
      envelopeId: envelopeId,
    );
    final updatedEnv = state.envelopes.map((e) {
      if (e.id != envelopeId) return e;
      return e.copyWith(spent: e.spent + amount.abs());
    }).toList();
    state = state.copyWith(
      transactions: [...state.transactions, tx],
      envelopes: updatedEnv,
    );
    _persist();
  }

  void depositToCitadel(double amount) {
    state = state.copyWith(
      citadel: state.citadel.copyWith(saved: state.citadel.saved + amount),
    );
    _persist();
  }

  /// Reforçar um cofre — puxa do pool "A ALOCAR".
  bool addAllocation({required String envelopeId, required double amount}) {
    if (amount <= 0) return false;
    if (state.availableToAssign < amount) return false;

    final updated = state.envelopes.map((e) {
      if (e.id != envelopeId) return e;
      return e.copyWith(allocated: e.allocated + amount);
    }).toList();
    state = state.copyWith(envelopes: updated);
    _persist();
    return true;
  }

  void reallocate({
    required String fromEnvelopeId,
    required String toEnvelopeId,
    required double amount,
  }) {
    final updated = state.envelopes.map((e) {
      if (e.id == fromEnvelopeId) {
        return e.copyWith(allocated: e.allocated - amount);
      }
      if (e.id == toEnvelopeId) {
        return e.copyWith(allocated: e.allocated + amount);
      }
      return e;
    }).toList();
    state = state.copyWith(envelopes: updated);
    _persist();
  }

  // ============================================================
  // CONFIGURAÇÃO (receita, cofres, cidadela)
  // ============================================================

  void setIncome(double newIncome) {
    state = state.copyWith(income: newIncome);
    _persist();
  }

  void setCitadel(CitadelGoal newGoal) {
    state = state.copyWith(citadel: newGoal);
    _persist();
  }

  /// Adiciona novo cofre (alocação 0 — depois reforça). Retorna o id.
  String addEnvelope({
    required String name,
    required EnvelopeKind kind,
    required IconData icon,
  }) {
    final id = 'env_${DateTime.now().millisecondsSinceEpoch}';
    final newEnv = Envelope(
      id: id,
      name: name,
      allocated: 0,
      spent: 0,
      kind: kind,
      icon: icon,
    );
    state = state.copyWith(envelopes: [...state.envelopes, newEnv]);
    _persist();
    return id;
  }

  void updateEnvelope(
    String envelopeId, {
    String? name,
    double? allocated,
    IconData? icon,
  }) {
    final updated = state.envelopes.map((e) {
      if (e.id != envelopeId) return e;
      return e.copyWith(name: name, allocated: allocated, icon: icon);
    }).toList();
    state = state.copyWith(envelopes: updated);
    _persist();
  }

  void deleteEnvelope(String envelopeId) {
    final updated =
        state.envelopes.where((e) => e.id != envelopeId).toList();
    // Transações órfãs voltam pro Inbox.
    final txs = state.transactions.map((t) {
      if (t.envelopeId != envelopeId) return t;
      return t.copyWith(clearEnvelope: true);
    }).toList();
    state = state.copyWith(envelopes: updated, transactions: txs);
    _persist();
  }

  // ============================================================
  // VIRADA DE MÊS
  // ============================================================

  /// Zera `spent` de todos os cofres (mantém `allocated`).
  /// Mantém transações antigas como histórico permanente.
  void closeMonth() {
    final updated =
        state.envelopes.map((e) => e.copyWith(spent: 0)).toList();
    state = state.copyWith(envelopes: updated);
    _persist();
  }

  // ============================================================
  // RESET / BACKUP
  // ============================================================

  Future<void> factoryReset() async {
    await _store.clear();
    state = _seed();
    await _store.save(state);
  }

  Future<String> exportRaw() => _store.exportRaw();
  Future<bool> importRaw(String raw) async {
    final ok = await _store.importRaw(raw);
    if (ok) {
      final loaded = await _store.load();
      if (loaded != null) state = loaded;
    }
    return ok;
  }

  // ============================================================
  // SEED INICIAL
  // ============================================================

  static AppState _seed() {
    final now = DateTime.now();
    return AppState(
      income: 0,
      citadel: CitadelGoal(
        target: 0,
        saved: 0,
        deadline: DateTime(now.year, 12, 31),
      ),
      envelopes: const [],
      transactions: const [],
    );
  }

  /// Mantido por compat (Settings antigo).
  void resetSeed() => factoryReset();
}

final appProvider =
    StateNotifierProvider<AppController, AppState>((ref) => AppController());
