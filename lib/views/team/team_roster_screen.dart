import 'package:cricbid/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../player/player_controller.dart';
import '../../core/widgets/app_widgets.dart';

class TeamRosterScreen extends StatelessWidget {
  const TeamRosterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final team = Get.arguments as TeamModel;
    final playerCtrl = Get.find<PlayerController>();
    return Scaffold(
      appBar: AppBar(title: Text('${team.name} Roster')),
      body: Obx(() {
        final players = playerCtrl.getPlayersForTeam(team.id);
        if (players.isEmpty) {
          return const Center(child: Text('No players in roster'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => PlayerCard(player: players[i]),
        );
      }),
    );
  }
}
