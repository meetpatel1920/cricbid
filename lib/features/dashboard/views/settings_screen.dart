import 'package:cricbid/app/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common/app_widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../group/controllers/group_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final groupCtrl = Get.find<GroupController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          _Section(
            title: 'Profile',
            children: [
              Obx(() {
                final user = authCtrl.currentUser.value;
                return ListTile(
                  leading: PlayerAvatar(
                    photoUrl: user?.photoUrl,
                    name: user?.name ?? '',
                    radius: 22,
                  ),
                  title: Text(user?.name ?? 'No name', style: theme.textTheme.titleSmall),
                  subtitle: Text('+91 ${authCtrl.phone}', style: theme.textTheme.bodySmall),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () => _editName(context, authCtrl),
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Appearance
          _Section(
            title: 'Appearance',
            children: [
              ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Theme Mode'),
                trailing: Obx(() {
                  final ctrl = Get.find<ThemeController>();
                  return DropdownButton<ThemeMode>(
                    value: ctrl.themeMode.value,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (v) => ctrl.setThemeMode(v!),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Group settings (admin only)
          Obx(() {
            if (authCtrl.currentRole.value != AppConstants.roleAdmin) {
              return const SizedBox.shrink();
            }
            final group = groupCtrl.group;
            return _Section(
              title: 'Group Settings',
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Group Name'),
                  subtitle: Text(group?.name ?? ''),
                  onTap: () => _editGroupName(context, groupCtrl),
                ),
                ListTile(
                  leading: const Icon(Icons.stars_outlined),
                  title: const Text('Points per Team'),
                  subtitle: Text('${group?.totalPointsPerTeam ?? 0} pts'),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward),
                  title: const Text('Min Player Points'),
                  subtitle: Text('${group?.minPlayerPoints ?? 1} pts'),
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Max Players / Team'),
                  subtitle: Text('${group?.maxPlayersPerTeam ?? 15}'),
                ),
              ],
            );
          }),

          const SizedBox(height: 12),

          // Groups
          _Section(
            title: 'My Groups',
            children: [
              ListTile(
                leading: const Icon(Icons.group_work_outlined),
                title: const Text('Switch / Manage Groups'),
                onTap: () => Get.toNamed(AppRoutes.groupList),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Create New Group'),
                onTap: () => Get.toNamed(AppRoutes.createGroup),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Account
          _Section(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.logout_outlined, color: AppColors.error),
                title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                onTap: authCtrl.signOut,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'CricBid v${AppConstants.appVersion}',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, AuthController authCtrl) {
    final ctrl = TextEditingController(text: authCtrl.currentUser.value?.name ?? '');
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Your name'),
          autofocus: true,
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

  void _editGroupName(BuildContext context, GroupController groupCtrl) {
    final ctrl = TextEditingController(text: groupCtrl.group?.name ?? '');
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Group name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              groupCtrl.updateGroupSettings(
                groupId: groupCtrl.groupId,
                name: ctrl.text.trim(),
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1) const Divider(height: 1, indent: 16),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
