import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/team_controller.dart';
import '../../player/controllers/player_controller.dart';
import '../../group/controllers/group_controller.dart';
import '../../../core/widgets/common/app_widgets.dart';
import '../../auth/models/app_models.dart';

// ════════════════════════════════════════════════════════════
//  ADD TEAM SCREEN
// ════════════════════════════════════════════════════════════
class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({super.key});
  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _ownerAddressCtrl = TextEditingController();
  final _lastTeamCtrl = TextEditingController();
  final _teamCtrl = Get.find<TeamController>();

  DateTime? _ownerBirthdate;
  String _ownerType = AppConstants.typeBatting;

  @override
  void dispose() {
    _teamNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _ownerAddressCtrl.dispose();
    _lastTeamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team'),
        actions: [
          TextButton.icon(
            onPressed: _importExcel,
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: const Text('Import'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Team Info', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Team Name *',
                controller: _teamNameCtrl,
                validator: (v) =>
                    (v?.trim().length ?? 0) < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Text('Owner Details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Owner Name *',
                controller: _ownerNameCtrl,
                validator: (v) =>
                    (v?.trim().length ?? 0) < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Owner Phone *',
                hint: '98XXXXXXXX',
                controller: _ownerPhoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v?.trim().length ?? 0) != 10 ? 'Enter 10 digits' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _ownerType,
                decoration: const InputDecoration(labelText: 'Owner Type *'),
                items: [
                  AppConstants.typeBatting,
                  AppConstants.typeBowling,
                  AppConstants.typeAllRounder,
                ]
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _ownerType = v!),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Date of Birth (Optional)',
                hint: 'DD/MM/YYYY',
                readOnly: true,
                controller: TextEditingController(
                  text: _ownerBirthdate != null
                      ? DateFormat('dd/MM/yyyy').format(_ownerBirthdate!)
                      : '',
                ),
                suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Address (Optional)',
                controller: _ownerAddressCtrl,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Last Playing Team (Optional)',
                controller: _lastTeamCtrl,
              ),
              const SizedBox(height: 24),
              Obx(() => AppButton(
                    label: 'Add Team',
                    width: double.infinity,
                    isLoading: _teamCtrl.isLoading.value,
                    onTap: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _ownerBirthdate = picked);
  }

  void _importExcel() => _teamCtrl.importTeamsFromExcel();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _teamCtrl.addTeam(
        name: _teamNameCtrl.text.trim(),
        ownerName: _ownerNameCtrl.text.trim(),
        ownerPhone: _ownerPhoneCtrl.text.trim(),
        ownerAddress: _ownerAddressCtrl.text.trim().isNotEmpty
            ? _ownerAddressCtrl.text.trim()
            : null,
        ownerBirthdate: _ownerBirthdate,
        ownerType: _ownerType,
        ownerLastTeam: _lastTeamCtrl.text.trim().isNotEmpty
            ? _lastTeamCtrl.text.trim()
            : null,
      );
    }
  }
}

// ════════════════════════════════════════════════════════════
//  TEAM LIST
// ════════════════════════════════════════════════════════════
class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamCtrl = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: Obx(() {
        if (teamCtrl.isLoading.value) return const AppLoader();
        final teams = teamCtrl.teams;
        if (teams.isEmpty) {
          return const Center(child: Text('No teams added yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => TeamCard(
            team: teams[i],
            onTap: () =>
                Get.toNamed(AppRoutes.teamDetail, arguments: teams[i]),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addTeam),
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Add Team'),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TEAM DETAIL
// ════════════════════════════════════════════════════════════
class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final team = Get.arguments as TeamModel;
    final theme = Theme.of(context);
    final playerCtrl = Get.find<PlayerController>();

    Color teamColor = theme.colorScheme.primary;
    if (team.themeColor != null) {
      try {
        teamColor = Color(int.parse(
            'FF${team.themeColor!.replaceAll('#', '')}',
            radix: 16));
      } catch (_) {}
    }

    final pct = team.totalPoints > 0
        ? (team.spentPoints / team.totalPoints).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () =>
                Get.toNamed(AppRoutes.teamTheme, arguments: team),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [teamColor, teamColor.withOpacity(0.75)],
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
                    child: team.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(team.logoUrl!,
                                fit: BoxFit.cover),
                          )
                        : const Icon(Icons.shield, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Owner: ${team.ownerName}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8)),
                        ),
                        Text(
                          team.ownerPhone,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget Used',
                          style: theme.textTheme.titleSmall),
                      Text(
                        '${team.spentPoints} / ${team.totalPoints} pts',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: teamColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: teamColor.withOpacity(0.15),
                      color: teamColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${team.playerCount} players',
                          style: theme.textTheme.bodySmall),
                      Text('${team.remainingPoints} pts remaining',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: teamColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Players
            Text('Players', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() {
              final teamPlayers = playerCtrl.getPlayersForTeam(team.id);
              if (teamPlayers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: const Center(
                    child: Text('No players yet'),
                  ),
                );
              }
              return Column(
                children: teamPlayers
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PlayerCard(
                            player: p,
                            teamColor: teamColor,
                            showStatus: false,
                          ),
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

// ════════════════════════════════════════════════════════════
//  TEAM ROSTER
// ════════════════════════════════════════════════════════════
class TeamRosterScreen extends StatelessWidget {
  const TeamRosterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final team = Get.arguments as TeamModel;
    final playerCtrl = Get.find<PlayerController>();
    return Scaffold(
      appBar: AppBar(title: Text('${team.name} Roster')),
      body: Obx(() {
        final players = playerCtrl.getPlayersForTeam(team.id);
        if (players.isEmpty) {
          return const Center(child: Text('No players in roster'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => PlayerCard(player: players[i]),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TEAM THEME SCREEN (Owner sets logo + color)
// ════════════════════════════════════════════════════════════
class TeamThemeScreen extends StatefulWidget {
  const TeamThemeScreen({super.key});
  @override
  State<TeamThemeScreen> createState() => _TeamThemeScreenState();
}

class _TeamThemeScreenState extends State<TeamThemeScreen> {
  final _teamCtrl = Get.find<TeamController>();
  Color _selectedColor = AppColors.primary;
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final team = Get.arguments as TeamModel?;
    if (team == null) return const Scaffold(body: Center(child: Text('No team')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Theme'),
        actions: [
          if (_changed)
            TextButton(
              onPressed: () async {
                final hex =
                    '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
                await _teamCtrl.updateTeamTheme(team.id, hex);
                Get.back();
                Get.snackbar('Saved', 'Team theme updated!');
              },
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick Team Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (c) =>
                  setState(() {
                    _selectedColor = c;
                    _changed = true;
                  }),
              pickerAreaHeightPercent: 0.5,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithSaturation,
            ),
            const SizedBox(height: 20),
            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_selectedColor, _selectedColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This color will be applied to all players in your team within this group.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
