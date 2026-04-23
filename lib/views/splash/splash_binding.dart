import 'package:get/get.dart';
import 'splash_controller.dart';
import '../auth/auth_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
