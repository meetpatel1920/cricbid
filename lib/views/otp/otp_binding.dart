import 'package:get/get.dart';
import 'otp_controller.dart';
import '../auth/auth_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
