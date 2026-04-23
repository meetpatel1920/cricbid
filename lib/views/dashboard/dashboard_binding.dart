import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../player/player_controller.dart';
import '../team/team_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    if (!Get.isRegistered<PlayerController>()) Get.put(PlayerController());
    if (!Get.isRegistered<TeamController>()) Get.put(TeamController());
  }
}
