import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/common/app_widgets.dart';
import '../controllers/timetable_controller.dart';
import '../../group/controllers/group_controller.dart';
import '../../auth/models/app_models.dart';

// ════════════════════════════════════════════════════════════
//  TIMETABLE SCREEN
// ════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════
//  CREATE TIMETABLE SCREEN
// ════════════════════════════════════════════════════════════
class CreateTimetableScreen extends StatefulWidget {
  const CreateTimetableScreen({super.key});
  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Tournament 2026');
  final _matchesPerDayCtrl = TextEditingController(text: '2');
  final _ttCtrl = Get.find<TimetableController>();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));
  bool _useGroups = false;
  int _numGroups = 4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _matchesPerDayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Timetable')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Tournament Name',
                controller: _nameCtrl,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'From Date',
                      readOnly: true,
                      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_fromDate)),
                      suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'To Date',
                      readOnly: true,
                      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_toDate)),
                      suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Matches Per Day',
                hint: '2',
                controller: _matchesPerDayCtrl,
                keyboardType: TextInputType.number,
                // inputFormatters: [
                //   FilteringTextInputFormatter.digitsOnly
                // ],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 6) {
                    return 'Enter 1-6';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Groups toggle
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Use Group Stage', style: theme.textTheme.titleSmall),
                              Text(
                                'Divide teams into groups (A, B, C...)',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _useGroups,
                          onChanged: (v) => setState(() => _useGroups = v),
                          activeColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    if (_useGroups) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Number of Groups:'),
                          const SizedBox(width: 16),
                          ...([2, 4, 8].map((n) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('$n'),
                                  selected: _numGroups == n,
                                  onSelected: (_) => setState(() => _numGroups = n),
                                ),
                              ))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A PDF will be auto-generated and shared after creation. All players will be notified.',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Obx(() => AppButton(
                    label: 'Generate Timetable',
                    icon: Icons.auto_awesome,
                    width: double.infinity,
                    isLoading: _ttCtrl.isLoading.value,
                    onTap: _submit,
                  )),

              Obx(() {
                if (_ttCtrl.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _ttCtrl.errorMessage.value,
                      style: const TextStyle(color: AppColors.error),
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

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate.add(const Duration(days: 30));
        }
      } else {
        _toDate = picked;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _ttCtrl.generateTimetable(
        name: _nameCtrl.text.trim(),
        fromDate: _fromDate,
        toDate: _toDate,
        matchesPerDay: int.parse(_matchesPerDayCtrl.text),
        useGroups: _useGroups,
        numGroups: _numGroups,
      );
    }
  }
}
