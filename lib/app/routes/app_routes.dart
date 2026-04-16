class AppRoutes {
  // Auth
  static const String splash = '/splash';
  static const String phoneLogin = '/login';
  static const String otpVerify = '/otp';

  // Group
  static const String noGroup = '/no-group';
  static const String createGroup = '/create-group';
  static const String groupList = '/group-list';
  static const String groupDetail = '/group-detail';

  // Dashboard (role-based)
  static const String adminDashboard = '/admin-dashboard';
  static const String ownerDashboard = '/owner-dashboard';
  static const String playerDashboard = '/player-dashboard';

  // Player
  static const String playerList = '/player-list';
  static const String addPlayer = '/add-player';
  static const String playerDetail = '/player-detail';
  static const String playerProfile = '/player-profile';

  // Team
  static const String teamList = '/team-list';
  static const String addTeam = '/add-team';
  static const String teamDetail = '/team-detail';
  static const String teamRoster = '/team-roster';

  // Auction
  static const String auctionDashboard = '/auction-dashboard';
  static const String auctionLive = '/auction-live';
  static const String auctionRound = '/auction-round';
  static const String auctionViewer = '/auction-viewer';
  static const String auctionHistory = '/auction-history';

  // Timetable
  static const String timetable = '/timetable';
  static const String createTimetable = '/create-timetable';

  // Chat
  static const String chat = '/chat';

  // Settings / Profile
  static const String settings = '/settings';
  static const String teamTheme = '/team-theme';
}
