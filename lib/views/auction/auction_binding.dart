import 'package:get/get.dart';
import 'auction_controller.dart';
import '../player/player_controller.dart';
import '../team/team_controller.dart';
import '../group/group_controller.dart';

class AuctionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GroupController>()) Get.put(GroupController());
    if (!Get.isRegistered<PlayerController>()) Get.put(PlayerController());
    if (!Get.isRegistered<TeamController>()) Get.put(TeamController());
    Get.lazyPut<AuctionController>(() => AuctionController(), fenix: true);
  }
}
