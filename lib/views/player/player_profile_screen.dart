import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_widgets.dart' hide AppButton;
import '../../core/widgets/button_widget.dart';
import '../../core/consts/app_consts.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';
import './player_controller.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final playerCtrl = Get.find<PlayerController>();
    final groupCtrl = Get.find<GroupController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        final user = authCtrl.currentUser.value;
        final role = authCtrl.currentRole.value;
        final group = groupCtrl.group;

        // Find this user's player record
        final myPlayer = playerCtrl.players.firstWhereOrNull(
          (p) => p.uid == authCtrl.uid || p.phone == authCtrl.phone,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Card ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    PlayerAvatar(
                      photoUrl: myPlayer?.photoUrl ?? user?.photoUrl,
                      name: user?.name ?? '',
                      radius: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name.isNotEmpty == true ? user!.name : 'Set your name',
                            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+91 ${authCtrl.phone}',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                      onPressed: () => _editName(context, authCtrl),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Group Info ─────────────────────────────────────────────
              if (group != null) ...[
                Text('Current Group',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 8),
                _InfoCard(
                  isDark: isDark,
                  children: [
                    _InfoRow(
                      icon: Icons.group_work_outlined,
                      label: 'Group',
                      value: group.name,
                    ),
                    _InfoRow(
                      icon: Icons.monetization_on_outlined,
                      label: 'Budget',
                      value: '${group.totalPointsPerTeam} pts',
                    ),
                    _InfoRow(
                      icon: Icons.people_outline,
                      label: 'Max Players',
                      value: '${group.maxPlayersPerTeam} per team',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // ── Player Stats (if registered as player) ─────────────────
              if (myPlayer != null) ...[
                Text('My Player Stats',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 8),
                _InfoCard(
                  isDark: isDark,
                  children: [
                    _InfoRow(
                      icon: Icons.sports_cricket,
                      label: 'Type',
                      value: myPlayer.type,
                    ),
                    if ((myPlayer.teamId ?? '').isNotEmpty)
                      _InfoRow(
                        icon: Icons.shield_outlined,
                        label: 'Team',
                        value: myPlayer.teamId ?? '',
                      ),
                    // _InfoRow(
                    //   icon: myPlayer.status == AppConsts.playerStatusSold ? Icons.check_circle_outline : Icons.pending_outlined,
                    //   label: 'Auction Status',
                    //   value: myPlayer.status.toUpperCase(),
                    // ),
                    _InfoRow(
                      icon: myPlayer.auctionStatus == AppConsts.playerStatusSold ? Icons.check_circle_outline : Icons.pending_outlined,
                      label: 'Auction Status',
                      value: myPlayer.auctionStatus.toUpperCase(),
                    ),
                    if ((myPlayer.soldPoints ?? 0) > 0)
                      _InfoRow(
                        icon: Icons.stars_outlined,
                        label: 'Sold For',
                        value: '${myPlayer.soldPoints ?? 0} pts',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // ── Switch Group ───────────────────────────────────────────
              AppButton(
                label: 'Switch / Manage Groups',
                width: double.infinity,
                icon: Icons.group_work_outlined,
                gradientColors: [
                  isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                  isDark ? AppColors.darkSurface : AppColors.white,
                ],
                onTap: () => Get.toNamed(AppRoutes.groupList),
              ),

              const SizedBox(height: 12),

              AppOutlinedButton(
                label: 'Sign Out',
                width: double.infinity,
                icon: Icons.logout_outlined,
                borderColor: AppColors.error,
                textColor: AppColors.error,
                onTap: authCtrl.signOut,
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  void _editName(BuildContext context, AuthController authCtrl) {
    final ctrl = TextEditingController(text: authCtrl.currentUser.value?.name ?? '');
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Your name'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              authCtrl.updateName(ctrl.text.trim());
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _InfoCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((e) => Column(children: [
                  e.value,
                  if (e.key < children.length - 1) const Divider(height: 1, indent: 16),
                ]))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: AppTextStyles.bodySmall),
      trailing: Text(value,
          style: AppTextStyles.labelMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )),
    );
  }
}
