import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

class LootZeroApp extends ConsumerWidget {
  const LootZeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Loot Zero',
      debugShowCheckedModeBanner: false,
      theme: LootZeroTheme.main,
      routerConfig: router,
    );
  }
}
