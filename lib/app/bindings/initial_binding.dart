import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/group/controllers/group_controller.dart';
import '../../core/utils/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(GroupController(), permanent: true);
    Get.lazyPut(() => NotificationService(), fenix: true);
  }
}
