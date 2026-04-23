import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../../core/consts/app_consts.dart';

class OtpController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  final otpController = TextEditingController();
  final nameController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool otpComplete = false.obs;

  String get phone => _authCtrl.phone;
  int get resendSeconds => _authCtrl.resendSeconds.value;
  String get errorMessage => _authCtrl.errorMessage.value;

  void onOtpChanged(String value) {
    if (_authCtrl.errorMessage.value.isNotEmpty) {
      _authCtrl.errorMessage.value = '';
    }
    otpComplete.value = value.length == 6;
    if (value.length == 6) verify(value);
  }

  Future<void> verify(String pin) async {
    if (pin.length < 6) return;
    isLoading.value = true;
    await _authCtrl.verifyOtp(
      pin,
      displayName: nameController.text.trim().isNotEmpty
          ? nameController.text.trim()
          : null,
    );
    isLoading.value = false;
  }

  Future<void> resendOtp() async {
    otpController.clear();
    otpComplete.value = false;
    await _authCtrl.sendOtp(phone);
  }

  @override
  void onClose() {
    otpController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
