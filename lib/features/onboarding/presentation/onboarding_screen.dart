import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/widgets/lz_logo.dart';
import '../../../core/widgets/mascot_zero.dart';
import '../../../core/widgets/coin_sprite.dart';
import '../../../domain/entities/citadel_goal.dart';
import '../../dashboard/presentation/widgets/citadel_card.dart';
import 'widgets/wildcard_chest_intro.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _totalPages = 5;

  void _next() {
    if (_page == _totalPages - 1) {
      widget.onFinished();
    } else {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() => widget.onFinished();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxSky(
        showHills: true,
        showGrass: true,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_page < _totalPages - 1)
                      GestureDetector(
                        onTap: _skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.ink.withOpacity(0.85),
                            border: Border.all(
                                color: AppColors.ink, width: 2),
                          ),
                          child: Text('PULAR',
                              style: AppTextStyles.badge
                                  .copyWith(color: AppColors.cloudWhite)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _ctrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [
                    _PageWelcome(),
                    _PageMission(),
                    _PageCitadel(),
                    _PageChest(),
                    _PageZero(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: i == _page ? 22 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? AppColors.goldCoin
                                : AppColors.cloudWhite.withOpacity(0.6),
                            border: Border.all(
                                color: AppColors.ink, width: 2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    PixelButton(
                      label: _page == _totalPages - 1
                          ? 'BORA JOGAR'
                          : 'PRÓXIMO',
                      icon: _page == _totalPages - 1
                          ? Icons.play_arrow
                          : Icons.arrow_forward,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingFrame extends StatelessWidget {
  const _OnboardingFrame({
    required this.title,
    required this.subtitle,
    required this.visual,
  });

  final String title;
  final String subtitle;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          visual
              .animate()
              .fadeIn(duration: 380.ms)
              .scale(
                  begin: const Offset(0.88, 0.88),
                  curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          PixelContainer(
            fill: AppColors.parchment,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardTitle),
                const SizedBox(height: 14),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 120.ms, duration: 400.ms)
              .slideY(begin: 0.2, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _PageWelcome extends StatelessWidget {
  const _PageWelcome();
  @override
  Widget build(BuildContext context) {
    return const _OnboardingFrame(
      visual: LzLogo(size: 180),
      title: 'BEM-VINDO AO LOOT ZERO',
      subtitle:
          'Sua jornada começa com R\$ 0,00 sem trabalho. Cada moeda vai ganhar uma missão. Bora?',
    );
  }
}

class _PageMission extends StatelessWidget {
  const _PageMission();
  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      visual: SizedBox(
        height: 170,
        child: PixelContainer(
          fill: AppColors.ink,
          padding: const EdgeInsets.all(22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CoinSprite(size: 52),
              const SizedBox(width: 14),
              Text('R\$',
                  style: AppTextStyles.hudTitle.copyWith(
                      color: AppColors.goldTone, fontSize: 22)),
              const SizedBox(width: 4),
              Text('0,00',
                  style: AppTextStyles.money.copyWith(
                      color: AppColors.emeraldTone, fontSize: 60)),
            ],
          ),
        ),
      ),
      title: 'A MISSÃO: ZERO SOBRA',
      subtitle:
          'Orçamento Base Zero: toda receita é alocada. O que sobra é R\$ 0,00 — porque tudo já tem um destino.',
    );
  }
}

class _PageCitadel extends StatelessWidget {
  const _PageCitadel();
  @override
  Widget build(BuildContext context) {
    final preview = CitadelGoal(
      target: 10000,
      saved: 6500,
      deadline: DateTime(DateTime.now().year, 12, 31),
    );
    return _OnboardingFrame(
      visual: CitadelCard(goal: preview),
      title: 'A CIDADELA',
      subtitle:
          'Sua grande meta de fim de ano. Você define o valor — o app te mostra se está no ritmo certo pra chegar lá.',
    );
  }
}

class _PageChest extends StatelessWidget {
  const _PageChest();
  @override
  Widget build(BuildContext context) {
    return const _OnboardingFrame(
      visual: WildcardChestIntro(),
      title: 'BAÚ CURINGA',
      subtitle:
          'Sua válvula de escape. Um fundo pequeno pra gastos por impulso, sem culpa — desde que tenha moedas dentro.',
    );
  }
}

class _PageZero extends StatelessWidget {
  const _PageZero();
  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      visual: Column(
        children: [
          const MascotZero(size: 160, mood: ZeroMood.angry),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.royalPurple,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Text('ZERO',
                style: AppTextStyles.badge
                    .copyWith(color: AppColors.cloudWhite, fontSize: 9)),
          ),
        ],
      ),
      title: 'CONHEÇA O ZERO',
      subtitle:
          'Seu guardião pixel. Quando você fura um cofre, ele aparece. Sem mimimi: vai te contar quantos dias atrasou a Cidadela.',
    );
  }
}
