import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/models/app_models.dart';

// ════════════════════════════════════════════════════════════
//  APP BUTTON
// ════════════════════════════════════════════════════════════
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOutlined ? c : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: c,
            side: BorderSide(color: c),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(backgroundColor: c),
        child: child,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  APP TEXT FIELD
// ════════════════════════════════════════════════════════════
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        prefixIcon: prefix,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  APP LOADER
// ════════════════════════════════════════════════════════════
class AppLoader extends StatelessWidget {
  final String? message;
  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SHIMMER CARD
// ════════════════════════════════════════════════════════════
class ShimmerCard extends StatelessWidget {
  final double height;
  const ShimmerCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
      highlightColor: isDark ? AppColors.darkBorder : AppColors.borderLight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PLAYER AVATAR
// ════════════════════════════════════════════════════════════
class PlayerAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final Color? borderColor;

  const PlayerAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 24,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _initial(theme, initial, radius),
                errorWidget: (_, __, ___) =>
                    _initial(theme, initial, radius),
              )
            : _initial(theme, initial, radius),
      ),
    );
  }

  Widget _initial(ThemeData theme, String initial, double radius) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PLAYER CARD
// ════════════════════════════════════════════════════════════
class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback? onTap;
  final bool showStatus;
  final Color? teamColor;

  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
    this.showStatus = true,
    this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    String statusLabel;
    switch (player.auctionStatus) {
      case AppConstants.playerStatusSold:
        statusColor = AppColors.soldGreen;
        statusLabel = 'Sold';
        break;
      case AppConstants.playerStatusSkipped:
        statusColor = AppColors.skipGray;
        statusLabel = 'Skipped';
        break;
      default:
        statusColor = theme.colorScheme.primary;
        statusLabel = 'Available';
    }

    final cardBorder = teamColor != null
        ? Border.all(color: teamColor!.withOpacity(0.4), width: 1.5)
        : Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: cardBorder,
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#${player.playerNumber}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Avatar
            PlayerAvatar(
              photoUrl: player.photoUrl,
              name: player.name,
              radius: 20,
              borderColor: teamColor,
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _TypeChip(type: player.type),
                      if (player.teamName != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            player.teamName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: teamColor ?? theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Status / Points
            if (showStatus) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (player.soldPoints != null)
                    Text(
                      '${player.soldPoints} pts',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TEAM CARD
// ════════════════════════════════════════════════════════════
class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback? onTap;
  final bool showBudget;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.showBudget = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color teamColor = theme.colorScheme.primary;
    if (team.themeColor != null) {
      try {
        teamColor =
            Color(int.parse('FF${team.themeColor!.replaceAll('#', '')}', radix: 16));
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.teamBorder(teamColor),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.teamSurface(teamColor, dark: isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.teamBorder(teamColor)),
              ),
              child: team.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: team.logoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.shield_outlined, color: teamColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    team.ownerName,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showBudget) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${team.remainingPoints} pts',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: teamColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${team.playerCount} players',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TYPE CHIP
// ════════════════════════════════════════════════════════════
class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (type) {
      case AppConstants.typeBowling:
        color = AppColors.error;
        icon = Icons.sports_cricket;
        break;
      case AppConstants.typeAllRounder:
        color = const Color(0xFF7C3AED);
        icon = Icons.star_half_rounded;
        break;
      default:
        color = AppColors.info;
        icon = Icons.sports_baseball;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            type,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LIVE AUCTION BADGE
// ════════════════════════════════════════════════════════════
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.liveRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 600.ms)
              .then()
              .fadeIn(duration: 600.ms),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SOLD ANIMATION OVERLAY
// ════════════════════════════════════════════════════════════
class SoldAnimationOverlay extends StatelessWidget {
  final String playerName;
  final String teamName;
  final int points;
  final String playerType;

  const SoldAnimationOverlay({
    super.key,
    required this.playerName,
    required this.teamName,
    required this.points,
    required this.playerType,
  });

  @override
  Widget build(BuildContext context) {
    final isBatter = playerType == AppConstants.typeBatting ||
        playerType == AppConstants.typeAllRounder;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated sport icon
            Text(
              isBatter ? '🏏' : '🎯',
              style: const TextStyle(fontSize: 80),
            )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.2, 1.2),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  end: const Offset(1, 1),
                  duration: 200.ms,
                ),
            const SizedBox(height: 20),
            // SOLD text
            Text(
              'SOLD!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
                letterSpacing: 4,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.3, end: 0, duration: 300.ms),
            const SizedBox(height: 12),
            Text(
              playerName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              'to $teamName',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                color: Colors.white70,
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '$points POINTS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SKIP ANIMATION OVERLAY
// ════════════════════════════════════════════════════════════
class SkipAnimationOverlay extends StatelessWidget {
  final String playerName;
  const SkipAnimationOverlay({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⏭️', style: TextStyle(fontSize: 60))
                .animate()
                .scale(duration: 300.ms, curve: Curves.easeOut),
            const SizedBox(height: 16),
            Text(
              'SKIPPED',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: AppColors.skipGray,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              playerName,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, color: Colors.white70),
            ).animate().fadeIn(delay: 250.ms),
          ],
        ),
      ),
    );
  }
}
