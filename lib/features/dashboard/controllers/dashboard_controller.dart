import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../group/controllers/group_controller.dart';
import '../../player/controllers/player_controller.dart';
import '../../team/controllers/team_controller.dart';

class DashboardController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();
  final GroupController _groupCtrl = Get.find<GroupController>();

  final RxInt selectedTabIndex = 0.obs;

  // Quick stats
  final RxInt totalPlayers = 0.obs;
  final RxInt soldPlayers = 0.obs;
  final RxInt unsoldPlayers = 0.obs;
  final RxInt totalTeams = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final playerCtrl = Get.find<PlayerController>();
      final teamCtrl = Get.find<TeamController>();

      totalPlayers.value = playerCtrl.players.length;
      soldPlayers.value = playerCtrl.soldPlayers.length;
      unsoldPlayers.value = playerCtrl.unsoldPlayers.length;
      totalTeams.value = teamCtrl.teams.length;
    } catch (_) {}
  }

  void refreshStats() => _loadStats();

  String get currentRole => _authCtrl.currentRole.value;
  String get groupName => _groupCtrl.group?.name ?? '';
  bool get isAuctionLive => _groupCtrl.group?.isAuctionLive ?? false;
}
