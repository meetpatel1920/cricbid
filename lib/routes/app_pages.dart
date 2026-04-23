import 'package:cricbid/views/timetable/create_timetable_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

// Auth / Splash / Login / OTP
import '../views/splash/splash_screen.dart';
import '../views/splash/splash_binding.dart';
import '../views/login/login_screen.dart';
import '../views/login/login_binding.dart';
import '../views/otp/otp_screen.dart';
import '../views/otp/otp_binding.dart';

// Group
import '../views/group/group_screen.dart'; // barrel: no_group, create, list
import '../views/group/group_controller.dart';
import '../views/group/group_binding.dart';

// Dashboard
import '../views/dashboard/dashboard_screen.dart'; // barrel: admin, owner, player
import '../views/dashboard/dashboard_controller.dart';
import '../views/dashboard/dashboard_binding.dart';
import '../views/dashboard/admin_dashboard_screen.dart';
import '../views/dashboard/owner_dashboard_screen.dart';
import '../views/dashboard/player_dashboard_screen.dart';

// Player
import '../views/player/player_screen.dart'; // barrel: list, add, detail, profile
import '../views/player/player_controller.dart';
import '../views/player/player_binding.dart';

// Team
import '../views/team/team_screen.dart'; // barrel: list, add, detail, roster, theme
import '../views/team/team_controller.dart';
import '../views/team/team_binding.dart';
import '../views/team/team_theme_screen.dart';

// Auction
import '../views/auction/auction_screen.dart';
import '../views/auction/auction_controller.dart';
import '../views/auction/auction_binding.dart';
import '../views/auction/auction_viewer_screen.dart';
import '../views/auction/auction_history_screen.dart';

// Timetable
import '../views/timetable/timetable_screen.dart';
import '../views/timetable/timetable_controller.dart';
import '../views/timetable/timetable_binding.dart';

// Chat
import '../views/chat/chat_screen.dart';
import '../views/chat/chat_controller.dart';
import '../views/chat/chat_binding.dart';

// Settings
import '../views/settings/settings_screen.dart';
import '../views/settings/settings_binding.dart';

class AppPages {
  static final pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    // Login
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    // OTP
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
      binding: GroupBinding(),
    ),
    GetPage(name: AppRoutes.createGroup, page: () => const CreateGroupScreen()),
    GetPage(name: AppRoutes.groupList, page: () => const GroupListScreen()),
    // Dashboard
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboard(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.ownerDashboard,
      page: () => const OwnerDashboard(),
      binding: DashboardBinding(),
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
      binding: PlayerBinding(),
    ),
    GetPage(name: AppRoutes.addPlayer, page: () => const AddPlayerScreen()),
    GetPage(name: AppRoutes.playerDetail, page: () => const PlayerDetailScreen()),
    GetPage(name: AppRoutes.playerProfile, page: () => const PlayerProfileScreen()),
    // Team
    GetPage(
      name: AppRoutes.teamList,
      page: () => const TeamListScreen(),
      binding: TeamBinding(),
    ),
    GetPage(name: AppRoutes.addTeam, page: () => const AddTeamScreen()),
    GetPage(name: AppRoutes.teamDetail, page: () => const TeamDetailScreen()),
    GetPage(name: AppRoutes.teamRoster, page: () => const TeamRosterScreen()),
    GetPage(name: AppRoutes.teamTheme, page: () => const TeamThemeScreen()),
    // Auction
    GetPage(
      name: AppRoutes.auctionDashboard,
      page: () => const AuctionDashboardScreen(),
      binding: AuctionBinding(),
    ),
    GetPage(name: AppRoutes.auctionLive, page: () => const AuctionLiveScreen()),
    GetPage(name: AppRoutes.auctionRound, page: () => const AuctionRoundScreen()),
    GetPage(
      name: AppRoutes.auctionViewer,
      page: () => const AuctionViewerScreen(),
      binding: AuctionBinding(),
    ),
    GetPage(name: AppRoutes.auctionHistory, page: () => const AuctionHistoryScreen()),
    // Timetable
    GetPage(
      name: AppRoutes.timetable,
      page: () => const TimetableScreen(),
      binding: TimetableBinding(),
    ),
    GetPage(name: AppRoutes.createTimetable, page: () => const CreateTimetableScreen()),
    // Chat
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),
    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
