import 'package:get/get.dart';
import '../views/auth/auth_controller.dart';
import '../views/group/group_controller.dart';
import '../services/notification_service.dart';
import '../core/theme/theme_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeService>(ThemeService(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<GroupController>(GroupController(), permanent: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
  }
}
