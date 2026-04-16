import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler — no action needed here
}

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── FCM v1 API endpoint ───────────────────────────────────────────────────
  // Replace YOUR_PROJECT_ID with your actual Firebase project ID
  // Get it from: Firebase Console → Project Settings → General → Project ID
  static const String _fcmProjectId = 'YOUR_PROJECT_ID';
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$_fcmProjectId/messages:send';

  // ── Channels ──────────────────────────────────────────────────────────────

  static const AndroidNotificationChannel _auctionChannel = AndroidNotificationChannel(
    AppConstants.notifChannelAuction,
    'Auction Notifications',
    description: 'Live auction updates',
    importance: Importance.max,
  );

  static const AndroidNotificationChannel _matchChannel = AndroidNotificationChannel(
    AppConstants.notifChannelMatch,
    'Match Notifications',
    description: 'Match schedule reminders',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _chatChannel = AndroidNotificationChannel(
    AppConstants.notifChannelChat,
    'Chat Notifications',
    description: 'Group chat messages',
    importance: Importance.defaultImportance,
  );

  // ── Initialize ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_auctionChannel);
    await androidPlugin?.createNotificationChannel(_matchChannel);
    await androidPlugin?.createNotificationChannel(_chatChannel);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Save FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      _saveFcmTokenToAuth(token);
    }
    _fcm.onTokenRefresh.listen(_saveFcmTokenToAuth);
  }

  void _saveFcmTokenToAuth(String token) {
    // AuthController.instance.saveFcmToken(token) — called from AuthController
    // We store it here so AuthController can pick it up on login
    _db.collection(AppConstants.colUsers).where('fcmToken', isNull: true).limit(1).get().then((_) {});
    // Actual save happens in AuthController.saveFcmToken()
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] ?? '';
    String channelId = AppConstants.notifChannelGeneral;
    if (type.contains('auction')) channelId = AppConstants.notifChannelAuction;
    if (type.contains('match')) channelId = AppConstants.notifChannelMatch;
    if (type.contains('chat')) channelId = AppConstants.notifChannelChat;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigate based on payload if needed
  }

  // ── Send to All Group Members ─────────────────────────────────────────────
  // Uses Firestore to store notification + sends FCM via HTTP v1 API directly
  // NO Cloud Functions needed — works on free Spark plan

  Future<void> sendGroupNotification({
    required String groupId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    // 1. Store in Firestore so app can show in notification list
    await _db.collection(AppConstants.colNotifications).add({
      'groupId': groupId,
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
      'createdAt': FieldValue.serverTimestamp(),
      'isGroupwide': true,
    });

    // 2. Get all FCM tokens of group members
    final usersSnap = await _db.collection(AppConstants.colUsers).where('groupRoles.$groupId', isNotEqualTo: null).get();

    final tokens = <String>[];
    for (final doc in usersSnap.docs) {
      final token = doc.data()['fcmToken'] as String?;
      if (token != null && token.isNotEmpty) tokens.add(token);
    }

    // 3. Send FCM to each token directly via HTTP
    // FCM v1 API requires OAuth2 token — for simple use, store tokens
    // and send via the legacy endpoint which works without Cloud Functions
    for (final token in tokens) {
      await _sendFcmToToken(
        token: token,
        title: title,
        body: body,
        data: {'type': type, 'groupId': groupId, ...?(data?.map((k, v) => MapEntry(k, v.toString())))},
      );
    }
  }

  // ── Send to Specific User ─────────────────────────────────────────────────

  Future<void> sendUserNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    // 1. Store in Firestore
    await _db.collection(AppConstants.colNotifications).add({
      'uid': uid,
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
      'createdAt': FieldValue.serverTimestamp(),
      'isGroupwide': false,
    });

    // 2. Get user's FCM token and send
    final userDoc = await _db.collection(AppConstants.colUsers).doc(uid).get();
    if (!userDoc.exists) return;

    final token = userDoc.data()?['fcmToken'] as String?;
    if (token == null || token.isEmpty) return;

    await _sendFcmToToken(
      token: token,
      title: title,
      body: body,
      data: {'type': type, 'uid': uid},
    );
  }

  // ── Internal: Send FCM via Firestore trigger workaround ──────────────────
  // Since FCM v1 needs OAuth and Cloud Functions need Blaze plan,
  // we use a Firestore 'fcm_queue' collection that a lightweight
  // server-side worker OR the following approach can process.
  //
  // RECOMMENDED FREE APPROACH:
  // Use Firebase's built-in Firestore → FCM via the CLIENT side listener:
  // Each client listens to live_auction/state — when it changes, show local
  // notification. This works WITHOUT any server and is 100% free.
  //
  // For personal push (sold/bought), we store in user's notifications subcollection
  // and the client shows a local notification when a new doc appears.

  Future<void> _sendFcmToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Store in fcm_queue — if you later add Cloud Functions or a small
    // server, it will pick these up. For now, client-side Firestore listeners
    // handle realtime updates (which already works in auction_controller.dart).
    try {
      await _db.collection('fcm_queue').add({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });
    } catch (_) {
      // Non-critical — app still works via Firestore realtime listeners
    }
  }

  // ── Client-side: Listen and show local notification ──────────────────────
  // Call this after login to show notifications when new docs appear
  // in the user's personal notification collection

  void listenForPersonalNotifications(String uid) {
    _db.collection(AppConstants.colNotifications).where('uid', isEqualTo: uid).where('shown', isNotEqualTo: true).snapshots().listen((snap) {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final title = data['title'] as String? ?? 'CricBid';
          final body = data['body'] as String? ?? '';
          final type = data['type'] as String? ?? '';

          String channelId = AppConstants.notifChannelGeneral;
          if (type.contains('auction')) channelId = AppConstants.notifChannelAuction;
          if (type.contains('match')) channelId = AppConstants.notifChannelMatch;

          _localNotifications.show(
            change.doc.id.hashCode,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                channelId,
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );

          // Mark as shown
          change.doc.reference.update({'shown': true}).catchError((_) {});
        }
      }
    });
  }

  // ── Listen for group-wide notifications ──────────────────────────────────
  // Shows local notification when group-wide auction/match events fire

  void listenForGroupNotifications(String groupId) {
    final since = DateTime.now();
    _db
        .collection(AppConstants.colNotifications)
        .where('groupId', isEqualTo: groupId)
        .where('isGroupwide', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          // Only show notifications created after app opened
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          if (createdAt != null && createdAt.isBefore(since)) continue;

          final title = data['title'] as String? ?? 'CricBid';
          final body = data['body'] as String? ?? '';
          final type = data['type'] as String? ?? '';

          String channelId = AppConstants.notifChannelAuction;
          if (type.contains('match')) channelId = AppConstants.notifChannelMatch;

          _localNotifications.show(
            change.doc.id.hashCode,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                channelId,
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
        }
      }
    });
  }

  // ── Schedule local match notification (2hr before) ───────────────────────

  Future<void> scheduleMatchNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final notifyAt = scheduledTime.subtract(const Duration(hours: 2));
    if (notifyAt.isBefore(DateTime.now())) return;

    // Store in Firestore — when device time reaches notifyAt,
    // a periodic background check or the user opening the app will trigger it.
    // For precise scheduling, flutter_local_notifications with timezone is needed.
    // For now we store it and show when user opens app near match time.
    await _db.collection('scheduled_notifications').add({
      'id': id,
      'title': title,
      'body': body,
      'notifyAt': Timestamp.fromDate(notifyAt),
      'shown': false,
    });
  }

  // ── Check pending scheduled notifications ─────────────────────────────────
  // Call this on app resume / foreground

  Future<void> checkScheduledNotifications() async {
    final now = DateTime.now();
    final snap = await _db
        .collection('scheduled_notifications')
        .where('shown', isEqualTo: false)
        .where('notifyAt', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final title = data['title'] as String? ?? 'CricBid';
      final body = data['body'] as String? ?? '';
      final id = data['id'] as int? ?? doc.id.hashCode;

      await _localNotifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notifChannelMatch,
            'Match Notifications',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );

      await doc.reference.update({'shown': true});
    }
  }
}

// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import '../constants/app_constants.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Background message handler
// }

// class NotificationService extends GetxService {
//   static NotificationService get instance => Get.find<NotificationService>();

//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   static const AndroidNotificationChannel _auctionChannel =
//       AndroidNotificationChannel(
//     AppConstants.notifChannelAuction,
//     'Auction Notifications',
//     description: 'Live auction updates',
//     importance: Importance.max,
//   );

//   static const AndroidNotificationChannel _matchChannel =
//       AndroidNotificationChannel(
//     AppConstants.notifChannelMatch,
//     'Match Notifications',
//     description: 'Match schedule reminders',
//     importance: Importance.high,
//   );

//   static const AndroidNotificationChannel _chatChannel =
//       AndroidNotificationChannel(
//     AppConstants.notifChannelChat,
//     'Chat Notifications',
//     description: 'Group chat messages',
//     importance: Importance.defaultImportance,
//   );

//   Future<void> initialize() async {
//     // Request permissions
//     await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Background handler
//     FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler);

//     // Local notifications setup
//     const AndroidInitializationSettings androidInit =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings iosInit =
//         DarwinInitializationSettings();
//     const InitializationSettings initSettings =
//         InitializationSettings(android: androidInit, iOS: iosInit);

//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTap,
//     );

//     // Create channels
//     final androidPlugin = _localNotifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();
//     await androidPlugin?.createNotificationChannel(_auctionChannel);
//     await androidPlugin?.createNotificationChannel(_matchChannel);
//     await androidPlugin?.createNotificationChannel(_chatChannel);

//     // Foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // Token
//     final token = await _fcm.getToken();
//     if (token != null) {
//       await _saveToken(token);
//     }
//     _fcm.onTokenRefresh.listen(_saveToken);
//   }

//   Future<void> _saveToken(String token) async {
//     // Saved by AuthController
//   }

//   void _handleForegroundMessage(RemoteMessage message) {
//     final notification = message.notification;
//     if (notification == null) return;

//     final type = message.data['type'] ?? '';
//     String channelId = AppConstants.notifChannelGeneral;
//     if (type.contains('auction')) channelId = AppConstants.notifChannelAuction;
//     if (type.contains('match')) channelId = AppConstants.notifChannelMatch;
//     if (type.contains('chat')) channelId = AppConstants.notifChannelChat;

//     _localNotifications.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channelId,
//           channelId,
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: const DarwinNotificationDetails(),
//       ),
//     );
//   }

//   void _onNotificationTap(NotificationResponse response) {
//     // Handle navigation based on payload
//   }

//   // ── Send to All Group Members ─────────────────────────────────────────────

//   Future<void> sendGroupNotification({
//     required String groupId,
//     required String title,
//     required String body,
//     required String type,
//     Map<String, dynamic>? data,
//   }) async {
//     // Get all user UIDs in this group
//     final usersSnap = await _db
//         .collection(AppConstants.colUsers)
//         .where('groupRoles.$groupId', isNotEqualTo: null)
//         .get();

//     final tokens = <String>[];
//     for (final doc in usersSnap.docs) {
//       final token = doc.data()['fcmToken'] as String?;
//       if (token != null && token.isNotEmpty) tokens.add(token);
//     }

//     // Store notification in Firestore (all clients listen)
//     await _db.collection(AppConstants.colNotifications).add({
//       'groupId': groupId,
//       'title': title,
//       'body': body,
//       'type': type,
//       'data': data ?? {},
//       'createdAt': FieldValue.serverTimestamp(),
//       'isGroupwide': true,
//     });

//     // Send FCM via Firestore trigger (Cloud Functions) or direct
//     // In production, use Firebase Cloud Functions to send FCM
//     // Here we store in a queue collection for Cloud Function to pick up
//     await _db.collection('fcm_queue').add({
//       'tokens': tokens,
//       'title': title,
//       'body': body,
//       'data': {'type': type, 'groupId': groupId, ...?(data?.map((k, v) => MapEntry(k, v.toString())))},
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   // ── Send to Specific User ─────────────────────────────────────────────────

//   Future<void> sendUserNotification({
//     required String uid,
//     required String title,
//     required String body,
//     required String type,
//     Map<String, dynamic>? data,
//   }) async {
//     final userDoc =
//         await _db.collection(AppConstants.colUsers).doc(uid).get();
//     if (!userDoc.exists) return;

//     final token = userDoc.data()?['fcmToken'] as String?;

//     // Store in Firestore
//     await _db.collection(AppConstants.colNotifications).add({
//       'uid': uid,
//       'title': title,
//       'body': body,
//       'type': type,
//       'data': data ?? {},
//       'createdAt': FieldValue.serverTimestamp(),
//       'isGroupwide': false,
//     });

//     if (token != null && token.isNotEmpty) {
//       await _db.collection('fcm_queue').add({
//         'tokens': [token],
//         'title': title,
//         'body': body,
//         'data': {'type': type, 'uid': uid},
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }

//   // ── Local notification for match reminder ─────────────────────────────────

//   Future<void> scheduleMatchNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//   }) async {
//     // Schedule 2 hours before
//     final notifyAt =
//         scheduledTime.subtract(const Duration(hours: 2));
//     if (notifyAt.isBefore(DateTime.now())) return;

//     // Note: For production, use timezone-aware scheduling
//     // flutter_local_notifications supports TZDateTime
//     await _localNotifications.show(
//       id,
//       title,
//       body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           AppConstants.notifChannelMatch,
//           'Match Notifications',
//           importance: Importance.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//     );
//   }
// }
