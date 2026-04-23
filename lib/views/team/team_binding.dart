import 'package:get/get.dart';
import 'team_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamController>(() => TeamController(), fenix: true);
  }
}
