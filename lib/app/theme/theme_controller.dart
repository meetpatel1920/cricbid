import 'package:cricbid/app/theme/app_theme.dart';
import 'package:cricbid/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<Color?> teamPrimaryColor = Rx<Color?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefThemeMode) ?? 'system';
    themeMode.value = _fromString(saved);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefThemeMode, _toString(mode));
  }

  /// Called when owner sets a team theme color
  void setTeamColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      teamPrimaryColor.value = null;
    } else {
      try {
        teamPrimaryColor.value = Color(
          int.parse('FF${hexColor.replaceAll('#', '')}', radix: 16),
        );
      } catch (_) {
        teamPrimaryColor.value = null;
      }
    }
    _rebuildTheme();
  }

  void _rebuildTheme() {
    Get.changeTheme(lightTheme);
    Get.changeTheme(darkTheme);
  }

  ThemeData get lightTheme => AppTheme.lightTheme(teamPrimary: teamPrimaryColor.value);

  ThemeData get darkTheme => AppTheme.darkTheme(teamPrimary: teamPrimaryColor.value);

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
