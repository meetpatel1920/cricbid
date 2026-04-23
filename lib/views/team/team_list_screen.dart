import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import './team_controller.dart';
import '../../core/widgets/app_widgets.dart';

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamCtrl = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: Obx(() {
        if (teamCtrl.isLoading.value) return const AppLoader();
        final teams = teamCtrl.teams;
        if (teams.isEmpty) {
          return const Center(child: Text('No teams added yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => TeamCard(
            team: teams[i],
            onTap: () => Get.toNamed(AppRoutes.teamDetail, arguments: teams[i]),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addTeam),
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Add Team'),
      ),
    );
  }
}
