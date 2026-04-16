import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/player_controller.dart';
import '../../../core/widgets/common/app_widgets.dart';
import '../../auth/models/app_models.dart';

// ════════════════════════════════════════════════════════════
//  ADD PLAYER SCREEN
// ════════════════════════════════════════════════════════════
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
  String _type = AppConstants.typeBatting;
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
                          border: Border.all(
                              color: AppColors.border, width: 2),
                        ),
                        child: _previewPhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _previewPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _photoPlaceholder(),
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
                validator: (v) =>
                    (v?.trim().length ?? 0) < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone Number *',
                hint: '98XXXXXXXX',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v?.trim().length ?? 0) != 10 ? 'Enter 10 digits' : null,
              ),
              const SizedBox(height: 12),
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Player Type *'),
                items: [
                  AppConstants.typeBatting,
                  AppConstants.typeBowling,
                  AppConstants.typeAllRounder,
                ]
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              // Birthdate
              AppTextField(
                label: 'Date of Birth',
                hint: 'DD/MM/YYYY',
                readOnly: true,
                controller: TextEditingController(
                  text: _birthdate != null
                      ? DateFormat('dd/MM/yyyy').format(_birthdate!)
                      : '',
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
    return const Icon(Icons.add_a_photo_outlined,
        color: AppColors.textTertiary, size: 32);
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
        address: _addressCtrl.text.trim().isNotEmpty
            ? _addressCtrl.text.trim()
            : null,
        birthdate: _birthdate,
        type: _type,
        lastTeam: _lastTeamCtrl.text.trim().isNotEmpty
            ? _lastTeamCtrl.text.trim()
            : null,
        photoUrl: _previewPhotoUrl ??
            (_photoUrlCtrl.text.trim().isNotEmpty
                ? _photoUrlCtrl.text.trim()
                : null),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════
//  PLAYER LIST SCREEN (standalone)
// ════════════════════════════════════════════════════════════
class PlayerListScreen extends StatelessWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCtrl = Get.find<PlayerController>();
    return Scaffold(
      appBar: AppBar(title: const Text('All Players')),
      body: Obx(() {
        if (playerCtrl.isLoading.value) return const AppLoader();
        final players = playerCtrl.players;
        if (players.isEmpty) {
          return const Center(child: Text('No players yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => PlayerCard(
            player: players[i],
            onTap: () => Get.toNamed(AppRoutes.playerDetail,
                arguments: players[i]),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addPlayer),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Player'),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PLAYER DETAIL SCREEN
// ════════════════════════════════════════════════════════════
class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.arguments as PlayerModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color typeColor;
    switch (player.type) {
      case AppConstants.typeBowling:
        typeColor = AppColors.error;
        break;
      case AppConstants.typeAllRounder:
        typeColor = const Color(0xFF7C3AED);
        break;
      default:
        typeColor = AppColors.info;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  player.photoUrl != null
                      ? Image.network(player.photoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surface,
                          child: Center(
                            child: Text(
                              player.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary
                                    .withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                  // Gradient
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xDD000000),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Number badge
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${player.playerNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(player.name),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: typeColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      player.type,
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: player.phone,
                  ),
                  if (player.birthdate != null)
                    _DetailRow(
                      icon: Icons.cake_outlined,
                      label: 'Date of Birth',
                      value: DateFormat('dd MMM yyyy')
                          .format(player.birthdate!),
                    ),
                  if (player.address != null)
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: player.address!,
                    ),
                  if (player.lastTeam != null)
                    _DetailRow(
                      icon: Icons.history,
                      label: 'Last Team',
                      value: player.lastTeam!,
                    ),

                  // Auction result
                  if (player.isSold) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sold to ${player.teamName}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${player.soldPoints} points',
                                style: const TextStyle(
                                    color: AppColors.success),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text('$label: ',
              style: theme.textTheme.bodySmall),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PLAYER PROFILE (self-edit)
// ════════════════════════════════════════════════════════════
class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: const Center(child: Text('Player profile editing coming soon')),
    );
  }
}
