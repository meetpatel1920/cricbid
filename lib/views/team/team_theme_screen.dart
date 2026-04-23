import 'package:cricbid/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import './team_controller.dart';

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
                final hex = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
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
              onColorChanged: (c) => setState(() {
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
