import 'package:get/get.dart';
import 'package:cricbid/app/routes/app_routes.dart';
import '../../features/auction/views/admin/auction_screens.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/phone_login_screen.dart';
import '../../features/auth/views/otp_screen.dart';
import '../../features/auth/controllers/auth_controller.dart';

import '../../features/group/views/no_group_screen.dart';
import '../../features/group/views/create_group_screen.dart';
import '../../features/group/views/group_list_screen.dart';
import '../../features/group/controllers/group_controller.dart';

import '../../features/dashboard/views/admin_dashboard.dart';
import '../../features/dashboard/views/owner_dashboard.dart';
import '../../features/dashboard/views/player_dashboard.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';

import '../../features/player/views/player_list_screen.dart';
import '../../features/player/views/add_player_screen.dart';
import '../../features/player/views/player_detail_screen.dart';
import '../../features/player/views/player_profile_screen.dart';
import '../../features/player/controllers/player_controller.dart';

import '../../features/team/views/team_list_screen.dart';
import '../../features/team/views/add_team_screen.dart';
import '../../features/team/views/team_detail_screen.dart';
import '../../features/team/views/team_roster_screen.dart';
import '../../features/team/controllers/team_controller.dart';

import '../../features/auction/views/player/auction_viewer_screen.dart';
import '../../features/auction/views/shared/auction_history_screen.dart';
import '../../features/auction/controllers/auction_controller.dart';

import '../../features/timetable/views/timetable_screen.dart';
import '../../features/timetable/views/create_timetable_screen.dart';
import '../../features/timetable/controllers/timetable_controller.dart';

import '../../features/chat/views/chat_screen.dart';
import '../../features/chat/controllers/chat_controller.dart';

class AppPages {
  static final pages = [
    // ── Auth ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.phoneLogin,
      page: () => const PhoneLoginScreen(),
      binding: BindingsBuilder(() => Get.put(AuthController())),
    ),
    GetPage(
      name: AppRoutes.otpVerify,
      page: () => const OtpScreen(),
    ),

    // ── Group ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.noGroup,
      page: () => const NoGroupScreen(),
      binding: BindingsBuilder(() => Get.put(GroupController())),
    ),
    GetPage(
      name: AppRoutes.createGroup,
      page: () => const CreateGroupScreen(),
    ),
    GetPage(
      name: AppRoutes.groupList,
      page: () => const GroupListScreen(),
    ),

    // ── Dashboard ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboard(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(PlayerController());
        Get.put(TeamController());
      }),
    ),
    GetPage(
      name: AppRoutes.ownerDashboard,
      page: () => const OwnerDashboard(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(TeamController());
      }),
    ),
    GetPage(
      name: AppRoutes.playerDashboard,
      page: () => const PlayerDashboard(),
      binding: BindingsBuilder(() => Get.put(DashboardController())),
    ),

    // ── Players ───────────────────────────────────────────────
    GetPage(
      name: AppRoutes.playerList,
      page: () => const PlayerListScreen(),
      binding: BindingsBuilder(() => Get.put(PlayerController())),
    ),
    GetPage(
      name: AppRoutes.addPlayer,
      page: () => const AddPlayerScreen(),
    ),
    GetPage(
      name: AppRoutes.playerDetail,
      page: () => const PlayerDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.playerProfile,
      page: () => const PlayerProfileScreen(),
    ),

    // ── Teams ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.teamList,
      page: () => const TeamListScreen(),
      binding: BindingsBuilder(() => Get.put(TeamController())),
    ),
    GetPage(
      name: AppRoutes.addTeam,
      page: () => const AddTeamScreen(),
    ),
    GetPage(
      name: AppRoutes.teamDetail,
      page: () => const TeamDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.teamRoster,
      page: () => const TeamRosterScreen(),
    ),

    // ── Auction ───────────────────────────────────────────────
    GetPage(
      name: AppRoutes.auctionDashboard,
      page: () => const AuctionDashboardScreen(),
      binding: BindingsBuilder(() => Get.put(AuctionController())),
    ),
    GetPage(
      name: AppRoutes.auctionLive,
      page: () => const AuctionLiveScreen(),
    ),
    GetPage(
      name: AppRoutes.auctionRound,
      page: () => const AuctionRoundScreen(),
    ),
    GetPage(
      name: AppRoutes.auctionViewer,
      page: () => const AuctionViewerScreen(),
      binding: BindingsBuilder(() => Get.put(AuctionController())),
    ),
    GetPage(
      name: AppRoutes.auctionHistory,
      page: () => const AuctionHistoryScreen(),
    ),

    // ── Timetable ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.timetable,
      page: () => const TimetableScreen(),
      binding: BindingsBuilder(() => Get.put(TimetableController())),
    ),
    GetPage(
      name: AppRoutes.createTimetable,
      page: () => const CreateTimetableScreen(),
    ),

    // ── Chat ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: BindingsBuilder(() => Get.put(ChatController())),
    ),
  ];
}
