import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/app_repository.dart';

/// Persistência local via SharedPreferences + JSON.
/// Para o escopo pessoal do Loot Zero, é o suficiente — sem codegen,
/// fácil de exportar (string JSON = backup).
class LocalStore {
  static const _key = 'lz_state_v2';

  Future<AppState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppState.fromJson(json);
    } catch (e) {
      // Estado corrompido — retorna null pra cair no seed.
      return null;
    }
  }

  Future<void> save(AppState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Para backup: retorna o JSON cru (você pode mandar pra email, salvar
  /// em arquivo, etc).
  Future<String> exportRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '{}';
  }

  /// Para restaurar de backup.
  Future<bool> importRaw(String raw) async {
    try {
      // Valida que o JSON é parseável antes de gravar.
      AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, raw);
      return true;
    } catch (_) {
      return false;
    }
  }
}
