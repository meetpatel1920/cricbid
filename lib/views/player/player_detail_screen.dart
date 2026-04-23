import 'package:cricbid/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/consts/app_consts.dart';

class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.arguments as PlayerModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color typeColor;
    switch (player.type) {
      case AppConsts.typeBowling:
        typeColor = AppColors.error;
        break;
      case AppConsts.typeAllRounder:
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
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          child: Center(
                            child: Text(
                              player.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary.withOpacity(0.3),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor.withOpacity(0.3)),
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
                      value: DateFormat('dd MMM yyyy').format(player.birthdate!),
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
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
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
                                style: const TextStyle(color: AppColors.success),
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
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text('$label: ', style: theme.textTheme.bodySmall),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
