import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../player/player_controller.dart';
import '../../core/widgets/app_widgets.dart';

class AllPlayersTab extends StatelessWidget {
  const AllPlayersTab();
  @override
  Widget build(BuildContext context) {
    final playerCtrl = Get.find<PlayerController>();
    return Obx(() {
      if (playerCtrl.isLoading.value) return const AppLoader();
      final players = playerCtrl.players;
      if (players.isEmpty) {
        return const Center(child: Text('No players in this group'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => PlayerCard(
          player: players[i],
          showStatus: true,
        ),
      );
    });
  }
}

class ChatTabPlaceholder extends StatelessWidget {
  const ChatTabPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppButton(
        label: 'Open Group Chat',
        icon: Icons.chat_bubble_outline,
        onTap: () => Get.toNamed(AppRoutes.chat),
      ),
    );
  }
}
