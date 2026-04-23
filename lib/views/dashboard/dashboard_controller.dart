import 'package:get/get.dart';
import '../../core/consts/app_consts.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';
import '../player/player_controller.dart';
import '../team/team_controller.dart';

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
