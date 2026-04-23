import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import './player_controller.dart';
import '../../core/widgets/app_widgets.dart';

class PlayerListScreen extends StatelessWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCtrl = Get.find<PlayerController>();
    return Scaffold(
      appBar: AppBar(title: const Text('All Players')),
      body: Obx(() {
        if (playerCtrl.isLoading.value) return const AppLoader();
        final players = playerCtrl.players;
        if (players.isEmpty) {
          return const Center(child: Text('No players yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => PlayerCard(
            player: players[i],
            onTap: () => Get.toNamed(AppRoutes.playerDetail, arguments: players[i]),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addPlayer),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Player'),
      ),
    );
  }
}
