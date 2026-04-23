import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void success({
    required String title,
    required String msg,
    int seconds = 2,
  }) =>
      _show(type: SnackType.success, title: title, msg: msg, seconds: seconds);

  static void error({
    required String title,
    required String msg,
    int seconds = 3,
  }) =>
      _show(type: SnackType.error, title: title, msg: msg, seconds: seconds);

  static void warning({
    required String title,
    required String msg,
    int seconds = 2,
  }) =>
      _show(type: SnackType.warning, title: title, msg: msg, seconds: seconds);

  static void info({
    required String title,
    required String msg,
    int seconds = 2,
  }) =>
      _show(type: SnackType.info, title: title, msg: msg, seconds: seconds);

  static void _show({
    required SnackType type,
    required String title,
    required String msg,
    required int seconds,
  }) {
    final cfg = _config(type);

    // Dismiss existing before showing
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(GetSnackBar(
      titleText: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cfg.iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(cfg.icon, color: cfg.iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 42),
        child: Text(
          msg,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 12),
        ),
      ),
      backgroundColor: cfg.bgColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: Duration(seconds: seconds),
      snackPosition: SnackPosition.TOP,
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      boxShadows: [
        BoxShadow(
          color: cfg.bgColor.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ));
  }

  static _SnackConfig _config(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackConfig(
          bgColor: const Color(0xFF0F3D1C),
          iconBg: AppColors.success.withOpacity(0.2),
          iconColor: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
        );
      case SnackType.error:
        return _SnackConfig(
          bgColor: const Color(0xFF3D0A0A),
          iconBg: AppColors.error.withOpacity(0.2),
          iconColor: const Color(0xFFFF6B6B),
          icon: Icons.error_outline_rounded,
        );
      case SnackType.warning:
        return _SnackConfig(
          bgColor: const Color(0xFF3D2800),
          iconBg: AppColors.warning.withOpacity(0.2),
          iconColor: AppColors.gold,
          icon: Icons.warning_amber_rounded,
        );
      case SnackType.info:
        return _SnackConfig(
          bgColor: const Color(0xFF002E3D),
          iconBg: AppColors.cyan.withOpacity(0.15),
          iconColor: AppColors.cyan,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _SnackConfig {
  final Color bgColor;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const _SnackConfig({
    required this.bgColor,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });
}
