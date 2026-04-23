import 'package:cricbid/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/consts/app_consts.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/pdf_generator.dart';

import '../group/group_controller.dart';
import '../player/player_controller.dart';
import '../team/team_controller.dart';
import './auction_controller.dart';

// ════════════════════════════════════════════════════════════
//  AUCTION DASHBOARD (admin pre-auction setup)
// ════════════════════════════════════════════════════════════
class AuctionDashboardScreen extends StatelessWidget {
  const AuctionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auctionCtrl = Get.find<AuctionController>();
    final playerCtrl = Get.find<PlayerController>();
    final groupCtrl = Get.find<GroupController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Auction Control')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Obx(() {
              final auction = auctionCtrl.currentAuction.value;
              final isLive = groupCtrl.group?.isAuctionLive ?? false;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLive ? AppColors.liveRed.withOpacity(0.1) : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLive ? AppColors.liveRed.withOpacity(0.3) : theme.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isLive ? AppColors.liveRed : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLive ? 'Auction is LIVE' : 'Auction Not Started',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isLive ? AppColors.liveRed : null,
                            ),
                          ),
                          if (auction != null)
                            Text(
                              'Round ${auction.currentRound} • Status: ${auction.status}',
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (isLive) const LiveBadge(),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Stats
            Obx(() {
              final total = playerCtrl.players.length;
              final sold = playerCtrl.soldPlayers.length;
              final unsold = playerCtrl.unsoldPlayers.length;
              return Row(
                children: [
                  Expanded(child: _AuctionStat(label: 'Total', value: '$total', color: AppColors.info)),
                  const SizedBox(width: 10),
                  Expanded(child: _AuctionStat(label: 'Sold', value: '$sold', color: AppColors.soldGreen)),
                  const SizedBox(width: 10),
                  Expanded(child: _AuctionStat(label: 'Remaining', value: '$unsold', color: AppColors.warning)),
                ],
              );
            }),
            const SizedBox(height: 20),

            // Actions
            Text('Actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            Obx(() {
              final isLive = groupCtrl.group?.isAuctionLive ?? false;
              final auction = auctionCtrl.currentAuction.value;
              final unsoldCount = playerCtrl.unsoldPlayers.length;

              return Column(
                children: [
                  // Start / Resume Auction
                  if (!isLive && unsoldCount > 0)
                    AppButton(
                      label: auction == null ? 'Start Auction (Round 1)' : 'Start Next Round',
                      icon: Icons.play_arrow_rounded,
                      width: double.infinity,
                      onTap: auction == null ? auctionCtrl.startAuction : auctionCtrl.startNextRound,
                    ),

                  if (isLive) ...[
                    AppButton(
                      label: 'Open Live Screen',
                      icon: Icons.open_in_full,
                      width: double.infinity,
                      onTap: () => Get.toNamed(AppRoute.auctionLive),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Pause Auction',
                      icon: Icons.pause_rounded,
                      width: double.infinity,
                      isOutlined: true,
                      onTap: auctionCtrl.pauseAuction,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Generate PDF
                  if (unsoldCount > 0)
                    OutlinedButton.icon(
                      onPressed: () => _generatePdf(playerCtrl, groupCtrl, auctionCtrl.currentRound.value?.roundNumber ?? 1),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Generate Auction PDF'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    ),
                ],
              );
            }),

            const SizedBox(height: 20),

            // Round list
            Obx(() {
              if (auctionCtrl.rounds.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rounds', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...auctionCtrl.rounds.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Text('Round ${r.roundNumber}', style: theme.textTheme.titleSmall),
                              const Spacer(),
                              Text(
                                '${r.playerIds.length} players',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: r.status == 'completed' ? AppColors.successSurface : AppColors.warningSurface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  r.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: r.status == 'completed' ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _generatePdf(PlayerController playerCtrl, GroupController groupCtrl, int round) async {
    final unsold = playerCtrl.unsoldPlayers;
    if (unsold.isEmpty) {
      Get.snackbar('No Players', 'No unsold players to generate PDF');
      return;
    }
    final file = await PdfGenerator.generateAuctionPdf(
      players: unsold,
      groupName: groupCtrl.group?.name ?? 'Auction',
      roundNumber: round,
    );
    await PdfGenerator.sharePdf(file, subject: 'Auction Round $round Player List');
  }
}

class _AuctionStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AuctionStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  AUCTION LIVE SCREEN (admin controls auction in real time)
// ════════════════════════════════════════════════════════════
class AuctionLiveScreen extends StatefulWidget {
  const AuctionLiveScreen({super.key});
  @override
  State<AuctionLiveScreen> createState() => _AuctionLiveScreenState();
}

class _AuctionLiveScreenState extends State<AuctionLiveScreen> {
  final _auctionCtrl = Get.find<AuctionController>();
  final _teamCtrl = Get.find<TeamController>();
  final _groupCtrl = Get.find<GroupController>();
  final _pointsCtrl = TextEditingController();

  String? _showOverlay; // 'sold' | 'skip'

  @override
  void initState() {
    super.initState();
    ever(_auctionCtrl.liveState, (state) {
      if (state?.lastAction == 'sold') {
        _showOverlayFor('sold');
      } else if (state?.lastAction == 'skip') {
        _showOverlayFor('skip');
      }
    });
  }

  void _showOverlayFor(String type) {
    setState(() => _showOverlay = type);
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _showOverlay = null);
    });
  }

  @override
  void dispose() {
    _pointsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final round = _auctionCtrl.currentRound.value;
          return Text('Round ${round?.roundNumber ?? 1} - Live');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_rounded),
            onPressed: () async {
              await _auctionCtrl.pauseAuction();
              Get.back();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Current player card (large)
              Expanded(
                flex: 3,
                child: Obx(() {
                  final player = _auctionCtrl.activePlayer.value;
                  final liveState = _auctionCtrl.liveState.value;

                  if (player == null) {
                    return const Center(child: Text('No active player'));
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Player number
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Player #${player.playerNumber}',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Photo
                        PlayerAvatar(
                          photoUrl: player.photoUrl,
                          name: player.name,
                          radius: 44,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          player.name,
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        _TypeChip(type: player.type),
                        if (player.lastTeam != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Last: ${player.lastTeam}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1);
                }),
              ),

              // Sold controls
              Expanded(
                flex: 2,
                child: Obx(() {
                  final player = _auctionCtrl.activePlayer.value;
                  if (player == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Team selector
                        DropdownButtonFormField<String>(
                          value: _auctionCtrl.selectedTeamId.value.isEmpty ? null : _auctionCtrl.selectedTeamId.value,
                          decoration: const InputDecoration(
                            labelText: 'Select Team',
                            prefixIcon: Icon(Icons.shield_outlined),
                          ),
                          items: _teamCtrl.teams
                              .map((t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text(
                                      '${t.name} (${t.remainingPoints} pts)',
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) _auctionCtrl.onTeamSelected(v);
                          },
                        ),
                        const SizedBox(height: 8),
                        // Points input
                        TextFormField(
                          controller: _pointsCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Points',
                            prefixIcon: const Icon(Icons.stars_outlined),
                            suffixText: 'pts',
                            errorText: _auctionCtrl.bidValidationError.value.isNotEmpty ? _auctionCtrl.bidValidationError.value : null,
                          ),
                          onChanged: (v) {
                            final pts = int.tryParse(v) ?? 0;
                            _auctionCtrl.onBidPointsChanged(pts);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _confirmSold(player),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.soldGreen,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                icon: const Icon(Icons.gavel_rounded),
                                label: const Text('SOLD'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => _auctionCtrl.skipPlayer(player.id),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                foregroundColor: AppColors.skipGray,
                                side: const BorderSide(color: AppColors.skipGray),
                              ),
                              icon: const Icon(Icons.skip_next_rounded),
                              label: const Text('Skip'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // Queue
              Container(
                height: 140,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Obx(() {
                  final round = _auctionCtrl.currentRound.value;
                  if (round == null) return const SizedBox.shrink();

                  final remaining = round.playerIds.skip(round.currentIndex).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Up Next (${remaining.length} left)',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: remaining.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final pid = remaining[i];
                            final p = Get.find<PlayerController>().players.firstWhereOrNull((p) => p.id == pid);
                            if (p == null) return const SizedBox(width: 60);
                            return Container(
                              width: 70,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: i == 0 ? theme.colorScheme.primaryContainer : theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                children: [
                                  PlayerAvatar(photoUrl: p.photoUrl, name: p.name, radius: 18),
                                  const SizedBox(height: 4),
                                  Text(
                                    '#${p.playerNumber}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),

          // Sold/Skip overlay
          if (_showOverlay != null)
            Positioned.fill(
              child: Obx(() {
                final state = _auctionCtrl.liveState.value;
                if (_showOverlay == 'sold' && state != null) {
                  return SoldAnimationOverlay(
                    playerName: state.currentPlayerName ?? '',
                    teamName: state.lastTeamName ?? '',
                    points: state.lastPoints ?? 0,
                    playerType: state.currentPlayerType ?? AppConsts.typeBatting,
                  );
                }
                if (_showOverlay == 'skip') {
                  return SkipAnimationOverlay(
                    playerName: _auctionCtrl.activePlayer.value?.name ?? '',
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
        ],
      ),
    );
  }

  void _confirmSold(PlayerModel player) {
    final teamId = _auctionCtrl.selectedTeamId.value;
    final points = int.tryParse(_pointsCtrl.text) ?? 0;

    if (teamId.isEmpty) {
      Get.snackbar('Error', 'Please select a team');
      return;
    }
    if (points <= 0) {
      Get.snackbar('Error', 'Enter valid points');
      return;
    }

    final team = _teamCtrl.teams.firstWhereOrNull((t) => t.id == teamId);

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Sale'),
        content: Text(
          '${player.name} → ${team?.name} for $points points?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _auctionCtrl.markSold(
                playerId: player.id,
                teamId: teamId,
                teamName: team?.name ?? '',
                points: points,
              );
              _pointsCtrl.clear();
            },
            child: const Text('Confirm Sold'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  AUCTION ROUND SCREEN
// ════════════════════════════════════════════════════════════
class AuctionRoundScreen extends StatelessWidget {
  const AuctionRoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const AuctionDashboardScreen();
  }
}

// Local reference to avoid import cycle
class AppRoute {
  static const String auctionLive = '/auction-live';
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case AppConsts.typeBowling:
        color = AppColors.error;
        break;
      case AppConsts.typeAllRounder:
        color = const Color(0xFF7C3AED);
        break;
      default:
        color = AppColors.info;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
