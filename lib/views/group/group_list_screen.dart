import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import './group_controller.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/app_widgets.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupCtrl = Get.find<GroupController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Get.toNamed(AppRoutes.createGroup),
          ),
        ],
      ),
      body: Obx(() {
        final groups = groupCtrl.myGroups;
        if (groups.isEmpty) {
          return const Center(child: Text('No groups found'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final group = groups[i];
            final role = authCtrl.currentUser.value?.groupRoles[group.id] ?? '';
            final isCurrent = group.id == authCtrl.currentGroupId.value;

            return GestureDetector(
              onTap: () => authCtrl.setCurrentGroup(group.id),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primarySurface : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? AppColors.primary.withOpacity(0.4) : theme.dividerColor,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sports_cricket,
                        color: isCurrent ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name, style: theme.textTheme.titleSmall),
                          Text(
                            role.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                    if (group.isAuctionLive) ...[
                      const SizedBox(width: 8),
                      const LiveBadge(),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
