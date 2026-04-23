import 'package:cricbid/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../player/player_controller.dart';
import '../../core/widgets/app_widgets.dart';

class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final team = Get.arguments as TeamModel;
    final theme = Theme.of(context);
    final playerCtrl = Get.find<PlayerController>();

    Color teamColor = theme.colorScheme.primary;
    if (team.themeColor != null) {
      try {
        teamColor = Color(int.parse('FF${team.themeColor!.replaceAll('#', '')}', radix: 16));
      } catch (_) {}
    }

    final pct = team.totalPoints > 0 ? (team.spentPoints / team.totalPoints).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Get.toNamed(AppRoutes.teamTheme, arguments: team),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [teamColor, teamColor.withOpacity(0.75)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: team.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(team.logoUrl!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.shield, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Owner: ${team.ownerName}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                        Text(
                          team.ownerPhone,
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget Used', style: theme.textTheme.titleSmall),
                      Text(
                        '${team.spentPoints} / ${team.totalPoints} pts',
                        style: theme.textTheme.titleSmall?.copyWith(color: teamColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: teamColor.withOpacity(0.15),
                      color: teamColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${team.playerCount} players', style: theme.textTheme.bodySmall),
                      Text('${team.remainingPoints} pts remaining', style: theme.textTheme.bodySmall?.copyWith(color: teamColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Players
            Text('Players', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() {
              final teamPlayers = playerCtrl.getPlayersForTeam(team.id);
              if (teamPlayers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: const Center(
                    child: Text('No players yet'),
                  ),
                );
              }
              return Column(
                children: teamPlayers
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PlayerCard(
                            player: p,
                            teamColor: teamColor,
                            showStatus: false,
                          ),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
