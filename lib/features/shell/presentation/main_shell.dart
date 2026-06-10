import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = <_NavItem>[
    _NavItem('/dashboard', Icons.map, 'MAPA'),
    _NavItem('/inbox', Icons.move_to_inbox, 'PORTAL'),
    _NavItem('/history', Icons.history, 'HIST'),
    _NavItem('/settings', Icons.settings, 'CONFIG'),
  ];

  int _indexOf(String loc) {
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _indexOf(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.inkLight, AppColors.ink],
          ),
          border: Border(
            top: BorderSide(color: AppColors.goldCoin, width: 3),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _TabBtn(
                  item: _tabs[i],
                  active: i == idx,
                  onTap: () => context.go(_tabs[i].path),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;
  const _NavItem(this.path, this.icon, this.label);
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.item,
    required this.active,
    required this.onTap,
  });
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = active ? AppColors.goldCoin : AppColors.parchment;
    final iconColor = active ? AppColors.ink : AppColors.citadelStoneDk;

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      transform: Matrix4.translationValues(0, active ? -2 : 0, 0),
      child: CustomPaint(
        painter: BevelPainter(fill: fill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: iconColor, size: 20),
              const SizedBox(height: 4),
              Text(item.label,
                  style: AppTextStyles.badge.copyWith(
                      fontSize: 7,
                      color: iconColor)),
            ],
          ),
        ),
      ),
    );

    if (active) {
      content = content.animate().scaleXY(
            begin: 0.92,
            end: 1.0,
            duration: 180.ms,
            curve: Curves.easeOut,
          );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
