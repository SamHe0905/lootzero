import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/coin_sprite.dart';
import '../../../core/widgets/mascot_balloon.dart';
import '../../../core/widgets/mascot_zero.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../domain/entities/envelope.dart';
import '../../../domain/enums/envelope_type.dart';
import '../../income/presentation/edit_income_sheet.dart';
import '../../citadel_detail/presentation/edit_citadel_sheet.dart';
import '../../envelope_manage/presentation/envelope_form_sheet.dart';
import 'widgets/citadel_card.dart';
import 'widgets/wildcard_chest_card.dart';
import 'widgets/envelope_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _zeroMessage;

  void _alertFromZero(Envelope env, int daysBehind) {
    setState(() {
      _zeroMessage = daysBehind > 0
          ? 'Você atrasou a Cidadela em $daysBehind dias. Mova suas moedas para cobrir "${env.name}" ou assuma o Game Over nessa categoria.'
          : 'O cofre "${env.name}" furou. Reforça ele com moedas de outro lugar ou aceita o Game Over por aqui.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final hasIncome = state.income > 0;
    final hasEnvelopes = state.envelopes.isNotEmpty;
    final hasCitadel = state.citadel.target > 0;

    // Welcome — tudo vazio
    if (!hasIncome && !hasEnvelopes && !hasCitadel) {
      return _WelcomeDashboard();
    }

    final yolo = state.envelopes
        .where((e) => e.kind == EnvelopeKind.yolo)
        .firstOrNull;
    final others =
        state.envelopes.where((e) => e.kind != EnvelopeKind.yolo).toList();
    final daysBehind = state.citadel.daysBehind(DateTime.now());

    return ParallaxSky(
      showHills: true,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _TopHud(
                toAssign: state.availableToAssign,
                hasIncome: hasIncome,
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.4, end: 0, curve: Curves.easeOut),
            ),

            if (_zeroMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _zeroMessage = null),
                    child: MascotBalloon(
                            message: _zeroMessage!, mood: ZeroMood.angry)
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .scale(
                            begin: const Offset(0.92, 0.92),
                            curve: Curves.easeOut),
                  ),
                ),
              ),

            if (hasCitadel)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: GestureDetector(
                    onTap: () => context.push('/citadel'),
                    child: CitadelCard(goal: state.citadel),
                  )
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOut),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _SetupCard(
                    title: 'DEFINIR A CIDADELA',
                    body: 'Sua grande meta de fim de ano. Quanto vai juntar?',
                    icon: Icons.castle,
                    onTap: () => showEditCitadelSheet(context, ref),
                  ),
                ),
              ),

            if (yolo != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WildcardChestCard(
                    yolo: yolo,
                    onTap: () {
                      if (yolo.isBroke) {
                        _alertFromZero(yolo, daysBehind);
                      } else {
                        context.push('/envelope/${yolo.id}');
                      }
                    },
                  )
                      .animate()
                      .fadeIn(delay: 160.ms, duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOut),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: AppColors.goldCoin),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SEUS COFRES',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.cloudWhite,
                        shadows: [
                          const Shadow(
                              offset: Offset(2, 2),
                              color: AppColors.ink,
                              blurRadius: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!hasEnvelopes)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SetupCard(
                    title: 'CRIAR PRIMEIRO COFRE',
                    body:
                        'Cofre = categoria (Aluguel, Comida, Pet…). Bota um Baú Curinga pros impulsos também.',
                    icon: Icons.add_box,
                    onTap: () => showEnvelopeFormSheet(context, ref),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final env = others[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: GestureDetector(
                        onTap: () {
                          if (env.isBroke) {
                            _alertFromZero(env, daysBehind);
                          } else {
                            context.push('/envelope/${env.id}');
                          }
                        },
                        child: EnvelopeTile(envelope: env),
                      )
                          .animate()
                          .fadeIn(
                              delay: (240 + i * 60).ms, duration: 320.ms)
                          .slideX(begin: 0.1, curve: Curves.easeOut),
                    );
                  },
                  childCount: others.length,
                ),
              ),

            if (hasEnvelopes)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: GestureDetector(
                    onTap: () => showEnvelopeFormSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cloudWhite.withOpacity(0.4),
                        border: Border.all(
                            color: AppColors.cloudWhite, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: AppColors.cloudWhite),
                          const SizedBox(width: 6),
                          Text('NOVO COFRE',
                              style: AppTextStyles.badge.copyWith(
                                  color: AppColors.cloudWhite)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TOP HUD — A ALOCAR
// ============================================================
class _TopHud extends StatelessWidget {
  const _TopHud({required this.toAssign, required this.hasIncome});
  final double toAssign;
  final bool hasIncome;

  @override
  Widget build(BuildContext context) {
    final zeroed = toAssign.abs() < 0.01;
    final color = !hasIncome
        ? AppColors.cloudWhite.withOpacity(0.6)
        : zeroed
            ? AppColors.emeraldTone
            : toAssign > 0
                ? AppColors.goldTone
                : AppColors.rubyTone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: PixelContainer(
        fill: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        bevel: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinSprite(size: 32),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A ALOCAR',
                        style: AppTextStyles.badge
                            .copyWith(color: AppColors.cloudWhite)),
                    const SizedBox(height: 2),
                    Text('ZBB: ideal = R\$ 0',
                        style: AppTextStyles.caption.copyWith(
                            color:
                                AppColors.cloudWhite.withOpacity(0.55))),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  money(toAssign),
                  style: AppTextStyles.moneySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    shadows: [
                      const Shadow(
                          offset: Offset(2, 2),
                          color: AppColors.ink,
                          blurRadius: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARD DE SETUP (placeholder estilizado pra ações vazias)
// ============================================================
class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PixelContainer(
      fill: AppColors.parchment,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.royalPurple,
              border: Border.all(color: AppColors.ink, width: 3),
            ),
            child: Icon(icon, color: AppColors.cloudWhite, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.citadelStoneDk),
        ],
      ),
    );
  }
}

// ============================================================
// WELCOME — primeira vez, tudo zerado
// ============================================================
class _WelcomeDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ParallaxSky(
      showHills: true,
      showGrass: true,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: const MascotZero(size: 130, mood: ZeroMood.happy)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.7, 0.7)),
              ),
              const SizedBox(height: 16),
              Text(
                'BORA CONFIGURAR',
                textAlign: TextAlign.center,
                style: AppTextStyles.hudTitle.copyWith(
                  color: AppColors.cloudWhite,
                  shadows: [
                    const Shadow(
                        offset: Offset(2, 2),
                        color: AppColors.ink,
                        blurRadius: 0),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Três passos pra começar a jogar:',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.cloudWhite.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),

              _SetupStep(
                number: 1,
                title: 'DEFINIR RECEITA',
                body: 'Quanto entra pra você por mês?',
                icon: Icons.attach_money,
                color: AppColors.emerald,
                onTap: () => showEditIncomeSheet(context, ref),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 320.ms)
                  .slideX(begin: -0.15),
              const SizedBox(height: 12),
              _SetupStep(
                number: 2,
                title: 'DEFINIR A CIDADELA',
                body: 'Sua grande meta + prazo.',
                icon: Icons.castle,
                color: AppColors.royalPurple,
                onTap: () => showEditCitadelSheet(context, ref),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 320.ms)
                  .slideX(begin: -0.15),
              const SizedBox(height: 12),
              _SetupStep(
                number: 3,
                title: 'CRIAR PRIMEIRO COFRE',
                body: 'Aluguel, Comida, Baú Curinga…',
                icon: Icons.add_box,
                color: AppColors.goldCoinDk,
                onTap: () => showEnvelopeFormSheet(context, ref),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 320.ms)
                  .slideX(begin: -0.15),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Pode pular passo, pode mexer depois. O Zero te avisa.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.cloudWhite.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({
    required this.number,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final int number;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PixelContainer(
      fill: AppColors.parchment,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.ink,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            alignment: Alignment.center,
            child: Text('$number',
                style: AppTextStyles.cardTitle
                    .copyWith(color: AppColors.goldCoin)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.ink, width: 3),
            ),
            child: Icon(icon, color: AppColors.cloudWhite, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.citadelStoneDk),
        ],
      ),
    );
  }
}
