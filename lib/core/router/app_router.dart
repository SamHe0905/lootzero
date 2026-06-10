import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/envelope_detail/presentation/envelope_detail_screen.dart';
import '../../features/citadel_detail/presentation/citadel_detail_screen.dart';
import '../../features/envelope_manage/presentation/manage_envelopes_screen.dart';

/// Bandeira "viu onboarding" persistida em SharedPreferences.
class OnboardingSeen {
  static const _key = 'onboarding_seen_v1';
  static Future<bool> get() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? false;
  }

  static Future<void> mark() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }

  static Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final seenProvider = ValueNotifier<bool?>(null);
  OnboardingSeen.get().then((v) => seenProvider.value = v);

  return GoRouter(
    refreshListenable: seenProvider,
    initialLocation: '/onboarding',
    redirect: (ctx, st) {
      final seen = seenProvider.value;
      if (seen == null) return null; // ainda carregando
      final atOnboarding = st.matchedLocation.startsWith('/onboarding');
      if (!seen && !atOnboarding) return '/onboarding';
      if (seen && atOnboarding) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => OnboardingScreen(
          onFinished: () async {
            await OnboardingSeen.mark();
            seenProvider.value = true;
          },
        ),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen()),
          GoRoute(
              path: '/inbox', builder: (_, __) => const InboxScreen()),
          GoRoute(
              path: '/history',
              builder: (_, __) => const HistoryScreen()),
          GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: '/envelope/:id',
        builder: (_, st) =>
            EnvelopeDetailScreen(envelopeId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: '/citadel',
        builder: (_, __) => const CitadelDetailScreen(),
      ),
      GoRoute(
        path: '/envelopes',
        builder: (_, __) => const ManageEnvelopesScreen(),
      ),
    ],
  );
});
