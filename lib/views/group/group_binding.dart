import 'package:get/get.dart';
import 'group_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupController>(() => GroupController(), fenix: true);
  }
}
