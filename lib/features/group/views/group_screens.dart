import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/group_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_models.dart';
import '../../../core/widgets/common/app_widgets.dart';

// ════════════════════════════════════════════════════════════
//  NO GROUP SCREEN
// ════════════════════════════════════════════════════════════
class NoGroupScreen extends StatelessWidget {
  const NoGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.group_work_outlined,
                      color: AppColors.primary, size: 40),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  'No Groups Yet',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'Create a new group to start your cricket auction, or wait to be added to one.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 36),
                AppButton(
                  label: 'Create New Group',
                  icon: Icons.add_rounded,
                  width: double.infinity,
                  onTap: () => Get.toNamed(AppRoutes.createGroup),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.find<AuthController>().signOut(),
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CREATE GROUP SCREEN
// ════════════════════════════════════════════════════════════
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _totalPtsCtrl = TextEditingController(text: '100');
  final _minPtsCtrl = TextEditingController(text: '1');
  final _maxPlayersCtrl = TextEditingController(text: '15');
  final _groupCtrl = Get.find<GroupController>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalPtsCtrl.dispose();
    _minPtsCtrl.dispose();
    _maxPlayersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Group Details', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Set up your cricket auction group',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Group Name',
                hint: 'e.g. IPL 2026-27',
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Min 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Auction Settings', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'These settings apply to all teams in this group',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Total Points / Team',
                      hint: '100',
                      controller: _totalPtsCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Min Player Points',
                      hint: '1',
                      controller: _minPtsCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Max Players per Team',
                hint: '15',
                controller: _maxPlayersCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Min player points determines the minimum bid per player. This helps owners plan their budget across all remaining players.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                    label: 'Create Group',
                    icon: Icons.check_rounded,
                    width: double.infinity,
                    isLoading: _groupCtrl.isLoading.value,
                    onTap: _submit,
                  )),
              Obx(() {
                if (_groupCtrl.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _groupCtrl.errorMessage.value,
                      style:
                          const TextStyle(color: AppColors.error),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _groupCtrl.createGroup(
        name: _nameCtrl.text.trim(),
        totalPointsPerTeam: int.parse(_totalPtsCtrl.text),
        minPlayerPoints: int.parse(_minPtsCtrl.text),
        maxPlayersPerTeam: int.parse(_maxPlayersCtrl.text),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════
//  GROUP LIST SCREEN
// ════════════════════════════════════════════════════════════
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
            final isCurrent =
                group.id == authCtrl.currentGroupId.value;

            return GestureDetector(
              onTap: () => authCtrl.setCurrentGroup(group.id),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primarySurface
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.primary.withOpacity(0.4)
                        : theme.dividerColor,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sports_cricket,
                        color: isCurrent
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name,
                              style: theme.textTheme.titleSmall),
                          Text(
                            role.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary),
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
