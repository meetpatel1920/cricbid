import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/common/app_widgets.dart';
import '../../controllers/auction_controller.dart';
import '../../../player/controllers/player_controller.dart';

class AuctionViewerScreen extends StatefulWidget {
  const AuctionViewerScreen({super.key});
  @override
  State<AuctionViewerScreen> createState() => _AuctionViewerScreenState();
}

class _AuctionViewerScreenState extends State<AuctionViewerScreen> {
  final _auctionCtrl = Get.find<AuctionController>();
  String? _showOverlay;

  @override
  void initState() {
    super.initState();
    ever(_auctionCtrl.liveState, (state) {
      if (state?.lastAction == 'sold') _triggerOverlay('sold');
      if (state?.lastAction == 'skip') _triggerOverlay('skip');
    });
  }

  void _triggerOverlay(String type) {
    setState(() => _showOverlay = type);
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _showOverlay = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Live Auction'), actions: const [LiveBadge()]),
      body: Stack(
        children: [
          Obx(() {
            final state = _auctionCtrl.liveState.value;
            if (state == null || !state.isLive) {
              return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.gavel, size: 64, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text('Auction not live yet'),
              ]));
            }
            return Column(
              children: [
                Expanded(child: Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Round \${state.currentRound}', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    PlayerAvatar(photoUrl: state.currentPlayerPhotoUrl, name: state.currentPlayerName ?? '', radius: 56),
                    const SizedBox(height: 16),
                    Text(state.currentPlayerName ?? '', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('Player #\${state.currentPlayerNumber}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ))),
                SizedBox(height: 200, child: Obx(() {
                  final events = _auctionCtrl.eventHistory;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (_, i) {
                      final e = events[i];
                      return ListTile(
                        dense: true,
                        title: Text(e.playerName),
                        trailing: Text(e.eventType == 'sold' ? '\${e.teamName} • \${e.points}pts' : 'SKIPPED',
                          style: TextStyle(color: e.eventType == 'sold' ? AppColors.success : AppColors.skipGray, fontWeight: FontWeight.w600)),
                      );
                    },
                  );
                })),
              ],
            );
          }),
          if (_showOverlay != null)
            Positioned.fill(child: Obx(() {
              final state = _auctionCtrl.liveState.value;
              if (_showOverlay == 'sold' && state != null) {
                return SoldAnimationOverlay(playerName: state.currentPlayerName ?? '', teamName: state.lastTeamName ?? '', points: state.lastPoints ?? 0, playerType: state.currentPlayerType ?? AppConstants.typeBatting);
              }
              if (_showOverlay == 'skip') {
                return SkipAnimationOverlay(playerName: _auctionCtrl.activePlayer.value?.name ?? '');
              }
              return const SizedBox.shrink();
            })),
        ],
      ),
    );
  }
}
