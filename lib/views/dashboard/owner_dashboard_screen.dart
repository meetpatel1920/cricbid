import './dashboard_widgets.dart';
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
//  OWNER DASHBOARD
// ════════════════════════════════════════════════════════════
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
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
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'signout') authCtrl.signOut();
              if (v == 'theme') Get.toNamed(AppRoutes.teamTheme);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'theme', child: Text('Team Theme')),
              const PopupMenuItem(value: 'signout', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _OwnerHome(),
          _OwnerPlayersTab(),
          AllPlayersTab(),
          ChatTabPlaceholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'My Team'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'My Players'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), activeIcon: Icon(Icons.format_list_bulleted), label: 'All Players'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}

class _OwnerHome extends StatelessWidget {
  const _OwnerHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final teamCtrl = Get.find<TeamController>();
    final groupCtrl = Get.find<GroupController>();

    return RefreshIndicator(
      onRefresh: () => teamCtrl.loadTeams(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final myTeam = teamCtrl.getOwnerTeam(authCtrl.currentUser.value?.uid ?? '');

          if (myTeam == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    const Icon(Icons.shield_outlined, size: 60, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('No team assigned yet', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Ask the admin to add your team',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          Color teamColor = theme.colorScheme.primary;
          if (myTeam.themeColor != null) {
            try {
              teamColor = Color(int.parse('FF${myTeam.themeColor!.replaceAll('#', '')}', radix: 16));
            } catch (_) {}
          }

          final minPoints = groupCtrl.minPlayerPoints;
          final playersNeeded = groupCtrl.maxPlayersPerTeam - myTeam.playerCount;
          final maxBid = myTeam.maxBidForPlayer(playersNeeded, minPoints);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [teamColor, teamColor.withOpacity(0.7)],
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
                      child: myTeam.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(myTeam.logoUrl!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.shield, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myTeam.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            myTeam.ownerName,
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Budget stats
              Row(
                children: [
                  Expanded(
                    child: _BudgetStat(
                      label: 'Total Budget',
                      value: '${myTeam.totalPoints} pts',
                      color: teamColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BudgetStat(
                      label: 'Remaining',
                      value: '${myTeam.remainingPoints} pts',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BudgetStat(
                      label: 'Spent',
                      value: '${myTeam.spentPoints} pts',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Max bid info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: teamColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Max bid for next player: $maxBid pts',
                            style: theme.textTheme.titleSmall?.copyWith(color: teamColor),
                          ),
                          Text(
                            'Need $playersNeeded more players • Min $minPoints pts each',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Players', style: theme.textTheme.titleMedium),
                  Text('${myTeam.playerCount} / ${groupCtrl.maxPlayersPerTeam}', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _OwnerPlayersTab extends StatelessWidget {
  const _OwnerPlayersTab();
  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final playerCtrl = Get.find<PlayerController>();
    final teamCtrl = Get.find<TeamController>();

    return Obx(() {
      final myTeam = teamCtrl.getOwnerTeam(authCtrl.currentUser.value?.uid ?? '');
      if (myTeam == null) return const Center(child: Text('No team assigned'));

      final myPlayers = playerCtrl.getPlayersForTeam(myTeam.id);
      if (myPlayers.isEmpty) {
        return const Center(child: Text('No players in your team yet'));
      }

      Color teamColor = Theme.of(context).colorScheme.primary;
      if (myTeam.themeColor != null) {
        try {
          teamColor = Color(int.parse('FF${myTeam.themeColor!.replaceAll('#', '')}', radix: 16));
        } catch (_) {}
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: myPlayers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => PlayerCard(
          player: myPlayers[i],
          teamColor: teamColor,
          onTap: () => Get.toNamed(AppRoutes.playerDetail, arguments: myPlayers[i]),
        ),
      );
    });
  }
}
