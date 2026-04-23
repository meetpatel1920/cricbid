import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import './group_controller.dart';
import '../../core/widgets/app_widgets.dart';

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
                    const Icon(Icons.info_outline, color: AppColors.info, size: 16),
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
