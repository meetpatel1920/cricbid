class AppConsts {
  // App Info
  static const String appName    = 'CricBid';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String colUsers          = 'users';
  static const String colGroups         = 'groups';
  static const String colTeams          = 'teams';
  static const String colPlayers        = 'players';
  static const String colAuctions       = 'auctions';
  static const String colAuctionRounds  = 'auction_rounds';
  static const String colBids           = 'bids';
  static const String colMessages       = 'messages';
  static const String colTimetables     = 'timetables';
  static const String colMatches        = 'matches';
  static const String colNotifications  = 'notifications';

  static const String subColMembers      = 'members';
  static const String subColRoundPlayers = 'round_players';

  // Roles
  static const String roleAdmin  = 'admin';
  static const String roleOwner  = 'owner';
  static const String rolePlayer = 'player';
  static const String roleViewer = 'viewer';

  // Player Types
  static const String typeBatting    = 'Batting';
  static const String typeBowling    = 'Bowling';
  static const String typeAllRounder = 'All-Rounder';

  // Auction Status
  static const String auctionStatusPending   = 'pending';
  static const String auctionStatusLive      = 'live';
  static const String auctionStatusPaused    = 'paused';
  static const String auctionStatusCompleted = 'completed';

  // Player Auction Status
  static const String playerStatusUnsold  = 'unsold';
  static const String playerStatusSold    = 'sold';
  static const String playerStatusSkipped = 'skipped';
  static const String playerStatusPending = 'pending';

  // Match Status
  static const String matchStatusScheduled = 'scheduled';
  static const String matchStatusLive      = 'live';
  static const String matchStatusCompleted = 'completed';

  // SharedPrefs Keys
  static const String prefThemeMode      = 'theme_mode';
  static const String prefCurrentGroupId = 'current_group_id';
  static const String prefUserId         = 'user_id';
  static const String prefFcmToken       = 'fcm_token';

  // Storage
  static const String storagePlayerImages = 'player_images';
  static const String storageTeamLogos    = 'team_logos';
  static const String storagePdfs         = 'pdfs';
  static const String storageTimetables   = 'timetables';

  // Default OTP (dev mode — Firebase OTP is disabled; use this)
  static const String devOtp = '123456';

  // Pagination
  static const int pageSize = 20;

  // Auction
  static const int auctionLiveRefreshMs    = 500;
  static const int animationSoldDurationMs = 3000;
  static const int animationSkipDurationMs = 1500;

  // Validation
  static const int minPlayerNameLength = 2;
  static const int maxPlayerNameLength = 50;
  static const int minGroupNameLength  = 3;
  static const int maxGroupNameLength  = 40;
  static const int phoneNumberLength   = 10;

  // PDF – A4
  static const double pdfPageWidth  = 595.0;
  static const double pdfPageHeight = 842.0;

  // Excel Column Indices – Teams
  static const int excelTeamName          = 0;
  static const int excelTeamOwnerName     = 1;
  static const int excelTeamOwnerPhone    = 2;
  static const int excelTeamOwnerAddress  = 3;
  static const int excelTeamOwnerBirthdate= 4;
  static const int excelTeamOwnerType     = 5;
  static const int excelTeamLastTeam      = 6;

  // Excel Column Indices – Players
  static const int excelPlayerName      = 0;
  static const int excelPlayerPhone     = 1;
  static const int excelPlayerAddress   = 2;
  static const int excelPlayerBirthdate = 3;
  static const int excelPlayerType      = 4;
  static const int excelPlayerLastTeam  = 5;
  static const int excelPlayerImageUrl  = 6;

  // Notification Channels
  static const String notifChannelAuction = 'auction_channel';
  static const String notifChannelMatch   = 'match_channel';
  static const String notifChannelGeneral = 'general_channel';
  static const String notifChannelChat    = 'chat_channel';

  // Timetable
  static const int maxGroupsInTournament  = 8;
  static const int minTeamsPerGroup       = 2;
  static const int maxMatchesPerDay       = 6;
  static const int notifyBeforeMatchMins  = 120;

  // Image
  static const int    maxImageSizeKB      = 500;
  static const double playerAvatarRadius  = 36.0;
  static const double teamLogoSize        = 56.0;
}
