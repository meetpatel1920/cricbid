import 'package:cricbid/models/app_models.dart';
import 'package:cricbid/views/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';
import '../team/team_controller.dart';
import '../player/player_controller.dart';
import '../../core/widgets/app_widgets.dart';

// ════════════════════════════════════════════════════════════
//  PLAYER DASHBOARD
// ════════════════════════════════════════════════════════════
class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});
  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final groupCtrl = Get.find<GroupController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(groupCtrl.group?.name ?? 'CricBid')),
        actions: [
          Obx(() {
            if (groupCtrl.group?.isAuctionLive ?? false) {
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.auctionViewer),
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: LiveBadge(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.group_outlined),
            onPressed: () => Get.toNamed(AppRoutes.groupList),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: authCtrl.signOut,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _PlayerHome(),
          AllPlayersTab(),
          ChatTabPlaceholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'My Status'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: 'All Players'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}

class _PlayerHome extends StatelessWidget {
  const _PlayerHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final playerCtrl = Get.find<PlayerController>();
    final teamCtrl = Get.find<TeamController>();

    return Obx(() {
      final uid = authCtrl.currentUser.value?.uid ?? '';
      PlayerModel? myPlayer;
      try {
        myPlayer = playerCtrl.players.firstWhere((p) => p.uid == uid || p.phone == authCtrl.phone);
      } catch (_) {}

      if (myPlayer == null) {
        return const Center(child: Text('Your player profile not found'));
      }

      TeamModel? myTeam;
      if (myPlayer.teamId != null) {
        try {
          myTeam = teamCtrl.teams.firstWhere((t) => t.id == myPlayer!.teamId);
        } catch (_) {}
      }

      Color teamColor = theme.colorScheme.primary;
      if (myTeam?.themeColor != null) {
        try {
          teamColor = Color(int.parse('FF${myTeam!.themeColor!.replaceAll('#', '')}', radix: 16));
        } catch (_) {}
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // My card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: myPlayer.isSold ? [teamColor, teamColor.withOpacity(0.7)] : [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  PlayerAvatar(
                    photoUrl: myPlayer.photoUrl,
                    name: myPlayer.name,
                    radius: 40,
                    borderColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    myPlayer.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '#${myPlayer.playerNumber} • ${myPlayer.type}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (myPlayer.isSold && myTeam != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Playing for ${myTeam.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sold for ${myPlayer.soldPoints} points',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ] else if (!myPlayer.isSold) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Available for Auction',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // My team roster (if sold)
            if (myTeam != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Team Roster', style: theme.textTheme.titleMedium),
                  Text(
                    myTeam.ownerName,
                    style: theme.textTheme.bodySmall?.copyWith(color: teamColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...playerCtrl.getPlayersForTeam(myTeam.id).map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PlayerCard(
                      player: p,
                      teamColor: teamColor,
                      showStatus: false,
                    ),
                  )),
            ],
          ],
        ),
      );
    });
  }
}
