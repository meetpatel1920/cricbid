import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../../core/consts/app_consts.dart';

class LoginController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number required';
    if (value.trim().length != AppConsts.phoneNumberLength) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  Future<void> sendOtp() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    await _authCtrl.sendOtp(phoneController.text.trim());
    isLoading.value = false;
  }

  RxString get errorMessage => _authCtrl.errorMessage;
}
