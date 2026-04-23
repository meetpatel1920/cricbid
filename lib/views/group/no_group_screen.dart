import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/app_widgets.dart';

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
                  child: const Icon(Icons.group_work_outlined, color: AppColors.primary, size: 40),
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
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
                    style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
