import 'package:cricbid/views/dashboard/owner_dashboard_screen.dart';
import 'package:cricbid/views/dashboard/player_dashboard_screen.dart';
import 'package:cricbid/views/group/create_group_screen.dart';
import 'package:cricbid/views/group/group_list_screen.dart';
import 'package:cricbid/views/group/no_group_screen.dart';
import 'package:cricbid/views/player/add_player_screen.dart';
import 'package:cricbid/views/player/player_detail_screen.dart';
import 'package:cricbid/views/player/player_list_screen.dart';
import 'package:cricbid/views/player/player_profile_screen.dart';
import 'package:cricbid/views/team/add_team_screen.dart';
import 'package:cricbid/views/team/team_detail_screen.dart';
import 'package:cricbid/views/team/team_list_screen.dart';
import 'package:cricbid/views/team/team_roster_screen.dart';
import 'package:cricbid/views/timetable/create_timetable_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

// Auth
import '../views/splash/splash_screen.dart';
import '../views/login/login_screen.dart';
import '../views/login/login_binding.dart';
import '../views/otp/otp_screen.dart';
import '../views/otp/otp_binding.dart';
import '../views/splash/splash_binding.dart';
import '../views/settings/settings_binding.dart';

// Group
import '../views/group/group_controller.dart';

// Dashboard
import '../views/dashboard/dashboard_controller.dart';
import '../views/dashboard/admin_dashboard_screen.dart';

// Player
import '../views/player/player_controller.dart';

// Team
import '../views/team/team_controller.dart';

// Auction
import '../views/auction/auction_screen.dart';
import '../views/auction/auction_controller.dart';
import '../views/auction/auction_viewer_screen.dart';
import '../views/auction/auction_history_screen.dart';

// Timetable
import '../views/timetable/timetable_screen.dart';
import '../views/timetable/timetable_controller.dart';

// Chat
import '../views/chat/chat_screen.dart';
import '../views/chat/chat_controller.dart';

// Settings
import '../views/settings/settings_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otpVerify,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
      transition: Transition.rightToLeft,
    ),
    // Group
    GetPage(
      name: AppRoutes.noGroup,
      page: () => const NoGroupScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<GroupController>()) Get.put(GroupController());
      }),
    ),
    GetPage(name: AppRoutes.createGroup, page: () => const CreateGroupScreen()),
    GetPage(name: AppRoutes.groupList, page: () => const GroupListScreen()),
    // Dashboard
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboard(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        if (!Get.isRegistered<PlayerController>()) Get.put(PlayerController());
        if (!Get.isRegistered<TeamController>()) Get.put(TeamController());
      }),
    ),
    GetPage(
      name: AppRoutes.ownerDashboard,
      page: () => const OwnerDashboard(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        if (!Get.isRegistered<TeamController>()) Get.put(TeamController());
      }),
    ),
    GetPage(
      name: AppRoutes.playerDashboard,
      page: () => const PlayerDashboard(),
      binding: BindingsBuilder(() => Get.put(DashboardController())),
    ),
    // Player
    GetPage(
      name: AppRoutes.playerList,
      page: () => const PlayerListScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PlayerController>()) Get.put(PlayerController());
      }),
    ),
    GetPage(name: AppRoutes.addPlayer, page: () => const AddPlayerScreen()),
    GetPage(name: AppRoutes.playerDetail, page: () => const PlayerDetailScreen()),
    GetPage(name: AppRoutes.playerProfile, page: () => const PlayerProfileScreen()),
    // Team
    GetPage(
      name: AppRoutes.teamList,
      page: () => const TeamListScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<TeamController>()) Get.put(TeamController());
      }),
    ),
    GetPage(name: AppRoutes.addTeam, page: () => const AddTeamScreen()),
    GetPage(name: AppRoutes.teamDetail, page: () => const TeamDetailScreen()),
    GetPage(name: AppRoutes.teamRoster, page: () => const TeamRosterScreen()),
    // Auction
    GetPage(
      name: AppRoutes.auctionDashboard,
      page: () => const AuctionDashboardScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuctionController>()) Get.put(AuctionController());
        if (!Get.isRegistered<PlayerController>()) Get.put(PlayerController());
        if (!Get.isRegistered<TeamController>()) Get.put(TeamController());
      }),
    ),
    GetPage(name: AppRoutes.auctionLive, page: () => const AuctionLiveScreen()),
    GetPage(name: AppRoutes.auctionRound, page: () => const AuctionRoundScreen()),
    GetPage(
      name: AppRoutes.auctionViewer,
      page: () => const AuctionViewerScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuctionController>()) Get.put(AuctionController());
      }),
    ),
    GetPage(name: AppRoutes.auctionHistory, page: () => const AuctionHistoryScreen()),
    // Timetable
    GetPage(
      name: AppRoutes.timetable,
      page: () => const TimetableScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<TimetableController>()) Get.put(TimetableController());
      }),
    ),
    GetPage(name: AppRoutes.createTimetable, page: () => const CreateTimetableScreen()),
    // Chat
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ChatController>()) Get.put(ChatController());
      }),
    ),
    // Settings
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen(), binding: SettingsBinding()),
  ];
}
