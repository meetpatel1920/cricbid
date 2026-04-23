import 'package:get/get.dart';
import 'login_controller.dart';
import '../auth/auth_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
