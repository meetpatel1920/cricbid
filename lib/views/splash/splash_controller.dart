import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      await auth.resolveNavigation();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
