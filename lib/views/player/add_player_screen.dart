import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/consts/app_consts.dart';
import './player_controller.dart';
import '../../core/widgets/app_widgets.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});
  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _lastTeamCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();
  final _playerCtrl = Get.find<PlayerController>();

  DateTime? _birthdate;
  String _type = AppConsts.typeBatting;
  String? _localImagePath;
  String? _previewPhotoUrl;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _lastTeamCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Player'),
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
              // Photo section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: _previewPhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _previewPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _photoPlaceholder(),
                                ),
                              )
                            : _photoPlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showImageOptions,
                      child: const Text('Add Photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'Player Name *',
                controller: _nameCtrl,
                validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone Number *',
                hint: '98XXXXXXXX',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.trim().length ?? 0) != 10 ? 'Enter 10 digits' : null,
              ),
              const SizedBox(height: 12),
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Player Type *'),
                items: [
                  AppConsts.typeBatting,
                  AppConsts.typeBowling,
                  AppConsts.typeAllRounder,
                ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              // Birthdate
              AppTextField(
                label: 'Date of Birth',
                hint: 'DD/MM/YYYY',
                readOnly: true,
                controller: TextEditingController(
                  text: _birthdate != null ? DateFormat('dd/MM/yyyy').format(_birthdate!) : '',
                ),
                suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Address (Optional)',
                controller: _addressCtrl,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Last Playing Team (Optional)',
                controller: _lastTeamCtrl,
              ),
              const SizedBox(height: 12),
              // Photo URL field
              AppTextField(
                label: 'Photo URL (Optional)',
                hint: 'https://...',
                controller: _photoUrlCtrl,
                onChanged: (v) {
                  if (v.isNotEmpty && Uri.tryParse(v)?.hasAbsolutePath == true) {
                    setState(() => _previewPhotoUrl = v);
                  }
                },
              ),
              const SizedBox(height: 24),
              Obx(() => AppButton(
                    label: 'Add Player',
                    width: double.infinity,
                    isLoading: _playerCtrl.isLoading.value,
                    onTap: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return const Icon(Icons.add_a_photo_outlined, color: AppColors.textTertiary, size: 32);
  }

  void _showImageOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Get.back();
                final url = await _playerCtrl.pickAndUploadImage(
                  playerId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  fromCamera: false,
                );
                if (url != null) setState(() => _previewPhotoUrl = url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () async {
                Get.back();
                final url = await _playerCtrl.pickAndUploadImage(
                  playerId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  fromCamera: true,
                );
                if (url != null) setState(() => _previewPhotoUrl = url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Paste Image URL'),
              onTap: () {
                Get.back();
                // Focus the URL field
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  void _importExcel() => _playerCtrl.importPlayersFromExcel();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _playerCtrl.addPlayer(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
        birthdate: _birthdate,
        type: _type,
        lastTeam: _lastTeamCtrl.text.trim().isNotEmpty ? _lastTeamCtrl.text.trim() : null,
        photoUrl: _previewPhotoUrl ?? (_photoUrlCtrl.text.trim().isNotEmpty ? _photoUrlCtrl.text.trim() : null),
      );
    }
  }
}
