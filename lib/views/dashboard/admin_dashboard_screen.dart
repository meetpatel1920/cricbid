import 'package:cricbid/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';
import '../player/player_controller.dart';
import '../team/team_controller.dart';
import './dashboard_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../utils/responsive_layout.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _AdminMobile(),
      desktop: _AdminDesktop(),
    );
  }
}

// ────────────────────────── MOBILE ──────────────────────────
class _AdminMobile extends StatefulWidget {
  const _AdminMobile();
  @override
  State<_AdminMobile> createState() => _AdminMobileState();
}

class _AdminMobileState extends State<_AdminMobile> {
  int _tab = 0;
  final _groupCtrl = Get.find<GroupController>();
  final _authCtrl = Get.find<AuthController>();
  final _playerCtrl = Get.find<PlayerController>();
  final _teamCtrl = Get.find<TeamController>();
  final _dashCtrl = Get.find<DashboardController>();

  final List<Widget> _pages = [
    const _DashHome(),
    const _PlayersTab(),
    const _TeamsTab(),
    const _AuctionTab(),
    const _ChatTabWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_groupCtrl.group?.name ?? 'CricBid')),
        actions: [
          Obx(() {
            if (_groupCtrl.group?.isAuctionLive ?? false) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.auctionLive),
                  child: const LiveBadge(),
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
              if (v == 'signout') _authCtrl.signOut();
              if (v == 'settings') Get.toNamed(AppRoutes.settings);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'signout', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Players'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Teams'),
            BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: 'Auction'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── DESKTOP ──────────────────────────
class _AdminDesktop extends StatefulWidget {
  const _AdminDesktop();
  @override
  State<_AdminDesktop> createState() => _AdminDesktopState();
}

class _AdminDesktopState extends State<_AdminDesktop> {
  int _idx = 0;

  final List<Widget> _pages = [
    const _DashHome(),
    const _PlayersTab(),
    const _TeamsTab(),
    const _AuctionTab(),
    const _ChatTabWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    final groupCtrl = Get.find<GroupController>();
    return DesktopShell(
      selectedIndex: _idx,
      onDestinationSelected: (i) => setState(() => _idx = i),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Players'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: Text('Teams'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel),
          label: Text('Auction'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: Text('Chat'),
        ),
      ],
      body: _pages[_idx],
    );
  }
}

// ────────────────────────── HOME TAB ──────────────────────────
class _DashHome extends StatelessWidget {
  const _DashHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playerCtrl = Get.find<PlayerController>();
    final teamCtrl = Get.find<TeamController>();
    final groupCtrl = Get.find<GroupController>();

    return RefreshIndicator(
      onRefresh: () async {
        await playerCtrl.loadPlayers();
        await teamCtrl.loadTeams();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Obx(() {
              final total = playerCtrl.players.length;
              final sold = playerCtrl.soldPlayers.length;
              final unsold = playerCtrl.unsoldPlayers.length;
              final teams = teamCtrl.teams.length;

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _StatCard(label: 'Total Players', value: '$total', icon: Icons.people, color: AppColors.info),
                  _StatCard(label: 'Sold', value: '$sold', icon: Icons.check_circle, color: AppColors.soldGreen),
                  _StatCard(label: 'Unsold', value: '$unsold', icon: Icons.hourglass_empty, color: AppColors.warning),
                  _StatCard(label: 'Teams', value: '$teams', icon: Icons.shield, color: AppColors.primary),
                ],
              );
            }),
            const SizedBox(height: 20),

            // Quick actions
            Text('Quick Actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickAction(
                  label: 'Add Player',
                  icon: Icons.person_add_outlined,
                  onTap: () => Get.toNamed(AppRoutes.addPlayer),
                ),
                _QuickAction(
                  label: 'Add Team',
                  icon: Icons.group_add_outlined,
                  onTap: () => Get.toNamed(AppRoutes.addTeam),
                ),
                _QuickAction(
                  label: 'Auction',
                  icon: Icons.gavel_outlined,
                  onTap: () => Get.toNamed(AppRoutes.auctionDashboard),
                  highlight: true,
                ),
                _QuickAction(
                  label: 'Timetable',
                  icon: Icons.calendar_month_outlined,
                  onTap: () => Get.toNamed(AppRoutes.timetable),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Team budget overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Team Budget Overview', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.teamList),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final teams = teamCtrl.teams;
              if (teams.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Center(
                    child: Text('No teams added yet', style: theme.textTheme.bodySmall),
                  ),
                );
              }
              return Column(
                children: teams
                    .take(5)
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TeamBudgetRow(team: t),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const _QuickAction({required this.label, required this.icon, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: highlight
              ? primary
              : isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: highlight ? null : Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: highlight ? Colors.white : primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: highlight ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamBudgetRow extends StatelessWidget {
  final TeamModel team;
  const _TeamBudgetRow({required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color teamColor = theme.colorScheme.primary;
    if (team.themeColor != null) {
      try {
        teamColor = Color(int.parse('FF${team.themeColor!.replaceAll('#', '')}', radix: 16));
      } catch (_) {}
    }

    final pct = team.totalPoints > 0 ? team.spentPoints / team.totalPoints : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(team.name, style: theme.textTheme.titleSmall)),
              Text(
                '${team.spentPoints}/${team.totalPoints} pts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: teamColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: teamColor.withOpacity(0.15),
              color: teamColor,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${team.playerCount} players',
                style: theme.textTheme.labelSmall,
              ),
              Text(
                '${team.remainingPoints} remaining',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────── PLAYERS TAB ──────────────────────────
class _PlayersTab extends StatelessWidget {
  const _PlayersTab();

  @override
  Widget build(BuildContext context) {
    final playerCtrl = Get.find<PlayerController>();
    return Scaffold(
      body: Obx(() {
        if (playerCtrl.isLoading.value) return const AppLoader();
        final players = playerCtrl.players;
        if (players.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Text('No players added yet'),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Add Players',
                  icon: Icons.add,
                  onTap: () => Get.toNamed(AppRoutes.addPlayer),
                ),
              ],
            ),
          );
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

// ────────────────────────── TEAMS TAB ──────────────────────────
class _TeamsTab extends StatelessWidget {
  const _TeamsTab();

  @override
  Widget build(BuildContext context) {
    final teamCtrl = Get.find<TeamController>();
    return Scaffold(
      body: Obx(() {
        if (teamCtrl.isLoading.value) return const AppLoader();
        final teams = teamCtrl.teams;
        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Text('No teams added yet'),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Add Team',
                  icon: Icons.add,
                  onTap: () => Get.toNamed(AppRoutes.addTeam),
                ),
              ],
            ),
          );
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
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'import_excel',
            onPressed: () => Get.find<TeamController>().importTeamsFromExcel(),
            mini: true,
            child: const Icon(Icons.upload_file_outlined),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.extended(
            heroTag: 'add_team',
            onPressed: () => Get.toNamed(AppRoutes.addTeam),
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('Add Team'),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────── AUCTION TAB ──────────────────────────
class _AuctionTab extends StatelessWidget {
  const _AuctionTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gavel, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Auction Control', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Manage your auction rounds', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          AppButton(
            label: 'Open Auction Dashboard',
            icon: Icons.open_in_new,
            onTap: () => Get.toNamed(AppRoutes.auctionDashboard),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────── CHAT TAB ──────────────────────────
class _ChatTabWrapper extends StatelessWidget {
  const _ChatTabWrapper();
  @override
  Widget build(BuildContext context) {
    // Defer to ChatScreen widget
    return const Center(
      child: Text('Chat — tap to open'),
    );
  }
}
