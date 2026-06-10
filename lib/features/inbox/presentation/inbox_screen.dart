import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/parallax_sky.dart';
import '../../../core/widgets/pixel_container.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../domain/entities/envelope.dart';
import '../../../domain/entities/transaction.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final inbox = state.inbox;

    return ParallaxSky(
      showHills: true,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: PixelContainer(
                  fill: AppColors.ink,
                  bevel: false,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.royalPurple,
                          border:
                              Border.all(color: AppColors.ink, width: 2),
                        ),
                        child: const Icon(Icons.move_to_inbox,
                            color: AppColors.cloudWhite, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PORTAL DE ENTRADA',
                                style: AppTextStyles.cardTitle
                                    .copyWith(color: AppColors.cloudWhite)),
                            const SizedBox(height: 2),
                            Text('Atribua cada moeda a um cofre',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.cloudWhite
                                        .withOpacity(0.6))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppColors.rubyRed,
                            border: Border.all(
                                color: AppColors.ink, width: 2)),
                        child: Text('${inbox.length}',
                            style: AppTextStyles.badge.copyWith(
                                color: AppColors.cloudWhite)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (inbox.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyInbox(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final tx = inbox[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _InboxItem(
                        tx: tx,
                        envelopes: state.envelopes,
                        onAssign: (envId) {
                          HapticService.coin();
                          ref
                              .read(appProvider.notifier)
                              .assignTransaction(tx.id, envId);
                        },
                      )
                          .animate()
                          .fadeIn(
                              delay: (i * 80).ms, duration: 280.ms)
                          .slideX(begin: 0.15, curve: Curves.easeOut),
                    );
                  },
                  childCount: inbox.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: PixelContainer(
          fill: AppColors.parchment,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  border: Border.all(color: AppColors.ink, width: 3),
                ),
                child: const Icon(Icons.check,
                    color: AppColors.cloudWhite, size: 32),
              ),
              const SizedBox(height: 12),
              Text('PORTAL VAZIO', style: AppTextStyles.cardTitle),
              const SizedBox(height: 8),
              Text('Nenhuma transação aguardando.',
                  style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxItem extends StatelessWidget {
  const _InboxItem({
    required this.tx,
    required this.envelopes,
    required this.onAssign,
  });

  final Transaction tx;
  final List<Envelope> envelopes;
  final void Function(String envelopeId) onAssign;

  void _showPicker(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        child: PixelContainer(
          fill: AppColors.parchment,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MOVER PARA QUAL COFRE?',
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 14),
              ...envelopes.map((e) => _EnvelopePickerTile(
                    envelope: e,
                    onTap: () {
                      Navigator.pop(ctx);
                      onAssign(e.id);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PixelContainer(
      fill: AppColors.cloudWhite,
      shadowOffset: 4,
      padding: const EdgeInsets.all(12),
      onTap: () => _showPicker(context),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.rubyRed,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child:
                const Icon(Icons.south, color: AppColors.cloudWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description.toUpperCase(),
                    style: AppTextStyles.badge.copyWith(fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')} • ${tx.merchant ?? "—"}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(money(tx.amount),
              style: AppTextStyles.moneySmall.copyWith(
                  color: AppColors.rubyRed, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EnvelopePickerTile extends StatelessWidget {
  const _EnvelopePickerTile(
      {required this.envelope, required this.onTap});
  final Envelope envelope;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: PixelContainer(
          fill: AppColors.cloudWhite,
          shadowOffset: 3,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppColors.emeraldDark,
                    border:
                        Border.all(color: AppColors.ink, width: 2)),
                child: Icon(envelope.icon,
                    color: AppColors.cloudWhite, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(envelope.name.toUpperCase(),
                    style: AppTextStyles.badge.copyWith(fontSize: 9)),
              ),
              Text(money(envelope.available),
                  style: AppTextStyles.body.copyWith(
                    color: envelope.isBroke
                        ? AppColors.rubyRed
                        : AppColors.emeraldDark,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
