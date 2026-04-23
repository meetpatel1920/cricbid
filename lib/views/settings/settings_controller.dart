import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_service.dart';
import '../auth/auth_controller.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = Get.find<ThemeService>();
  final AuthController _authCtrl = Get.find<AuthController>();

  RxBool get isDark => _themeService.isDark.obs;
  ThemeMode get themeMode => _themeService.themeMode.value;

  String get userName => _authCtrl.currentUser.value?.name ?? '';
  String get userPhone => _authCtrl.currentUser.value?.phone ?? '';
  String get userPhoto => _authCtrl.currentUser.value?.photoUrl ?? '';

  void toggleTheme() => _themeService.toggleTheme();

  void setTheme(ThemeMode mode) => _themeService.setTheme(mode);

  void signOut() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authCtrl.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
