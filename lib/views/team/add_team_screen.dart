import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/consts/app_consts.dart';
import './team_controller.dart';
import '../../core/widgets/app_widgets.dart';

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
  String _ownerType = AppConsts.typeBatting;

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
                validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Text('Owner Details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Owner Name *',
                controller: _ownerNameCtrl,
                validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Owner Phone *',
                hint: '98XXXXXXXX',
                controller: _ownerPhoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.trim().length ?? 0) != 10 ? 'Enter 10 digits' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _ownerType,
                decoration: const InputDecoration(labelText: 'Owner Type *'),
                items: [
                  AppConsts.typeBatting,
                  AppConsts.typeBowling,
                  AppConsts.typeAllRounder,
                ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _ownerType = v!),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Date of Birth (Optional)',
                hint: 'DD/MM/YYYY',
                readOnly: true,
                controller: TextEditingController(
                  text: _ownerBirthdate != null ? DateFormat('dd/MM/yyyy').format(_ownerBirthdate!) : '',
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
        ownerAddress: _ownerAddressCtrl.text.trim().isNotEmpty ? _ownerAddressCtrl.text.trim() : null,
        ownerBirthdate: _ownerBirthdate,
        ownerType: _ownerType,
        ownerLastTeam: _lastTeamCtrl.text.trim().isNotEmpty ? _lastTeamCtrl.text.trim() : null,
      );
    }
  }
}
