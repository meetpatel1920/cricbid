import 'package:cricbid/models/match_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import './timetable_controller.dart';
import '../group/group_controller.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ttCtrl = Get.find<TimetableController>();
    final groupCtrl = Get.find<GroupController>();
    final isAdmin = true; // replace with Get.find<AuthController>().currentRole.value == 'admin'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Timetable'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.upload_rounded),
              tooltip: 'Upload Custom Timetable',
              onPressed: ttCtrl.uploadCustomTimetable,
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => Get.toNamed('/create-timetable'),
            ),
        ],
      ),
      body: Obx(() {
        if (ttCtrl.isLoading.value) return const AppLoader();

        // Latest uploaded timetable image/pdf
        final timetableUrl = groupCtrl.group?.timetableUrl;
        final timetables = ttCtrl.timetables;
        final matches = ttCtrl.matches;

        return RefreshIndicator(
          onRefresh: ttCtrl.loadTimetables,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Uploaded timetable card
                if (timetableUrl != null && timetableUrl.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_month, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Official Timetable', style: theme.textTheme.titleSmall),
                              Text('Tap to view or share', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new_outlined, size: 20),
                          onPressed: () => launchUrl(Uri.parse(timetableUrl)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined, size: 20),
                          onPressed: () => Share.share(timetableUrl, subject: 'Match Timetable'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (matches.isEmpty && timetables.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 60, color: AppColors.textTertiary),
                          const SizedBox(height: 16),
                          Text('No timetable yet', style: theme.textTheme.titleMedium),
                          if (isAdmin) ...[
                            const SizedBox(height: 16),
                            AppButton(
                              label: 'Generate Timetable',
                              icon: Icons.auto_awesome,
                              onTap: () => Get.toNamed('/create-timetable'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                // Generated matches grouped by date
                if (matches.isNotEmpty) ...[
                  Text('Match Schedule', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ..._buildMatchGroups(context, matches),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildMatchGroups(BuildContext context, List<MatchModel> matches) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group by date
    final Map<String, List<MatchModel>> byDate = {};
    for (final m in matches) {
      final key = DateFormat('dd MMM yyyy').format(m.scheduledAt);
      byDate.putIfAbsent(key, () => []).add(m);
    }

    final widgets = <Widget>[];
    byDate.forEach((date, dayMatches) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );

      for (final match in dayMatches) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MatchCard(match: match),
          ),
        );
      }
    });

    return widgets;
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color stageColor;
    String stageLabel;
    if (match.stage == 'final') {
      stageColor = AppColors.accent;
      stageLabel = 'FINAL';
    } else if (match.stage.contains('semi')) {
      stageColor = const Color(0xFF7C3AED);
      stageLabel = 'SEMI';
    } else {
      stageColor = AppColors.primary;
      stageLabel = match.stage.toUpperCase().replaceAll('_', ' ');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: match.stage == 'final' ? AppColors.accent.withOpacity(0.3) : theme.dividerColor,
          width: match.stage == 'final' ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(match.scheduledAt),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'M${match.matchNumber}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Teams
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    match.team1Name,
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('VS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                Expanded(
                  child: Text(
                    match.team2Name,
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Stage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stageColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              stageLabel,
              style: TextStyle(
                fontSize: 9,
                color: stageColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
