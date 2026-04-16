import 'package:cricbid/core/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../models/app_models.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString verificationId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentGroupId = ''.obs;
  final RxString currentRole = ''.obs; // role in currentGroup

  // OTP timer
  final RxInt resendSeconds = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _loadSavedGroup();
  }

  Future<void> _loadSavedGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefCurrentGroupId) ?? '';
    currentGroupId.value = saved;
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.phoneLogin);
      return;
    }
    await _loadUserProfile(firebaseUser.uid);
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data()!, uid);
        await resolveNavigation();
      } else {
        // New user - go to profile setup (handled in OTP screen)
        Get.offAllNamed(AppRoutes.otpVerify);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile';
    }
  }

  Future<void> resolveNavigation() async {
    final user = currentUser.value;
    if (user == null) return;

    // Determine if user has any groups
    final groups = user.groupRoles;
    if (groups.isEmpty) {
      Get.offAllNamed(AppRoutes.noGroup);
      return;
    }

    // If we have a saved group, use it
    String groupId = currentGroupId.value;
    if (groupId.isEmpty || !groups.containsKey(groupId)) {
      groupId = groups.keys.first;
    }

// AuthController._resolveNavigation() ni ande, navigation pehla:
    NotificationService.instance.listenForPersonalNotifications(user.uid);
    NotificationService.instance.listenForGroupNotifications(groupId);

    await setCurrentGroup(groupId);
  }

  Future<void> setCurrentGroup(String groupId) async {
    final user = currentUser.value;
    if (user == null) return;

    currentGroupId.value = groupId;
    currentRole.value = user.groupRoles[groupId] ?? AppConstants.rolePlayer;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefCurrentGroupId, groupId);

    // Navigate based on role
    switch (currentRole.value) {
      case AppConstants.roleAdmin:
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case AppConstants.roleOwner:
        Get.offAllNamed(AppRoutes.ownerDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.playerDashboard);
    }
  }

  // ── Phone Login ──────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone) async {
    isLoading.value = true;
    errorMessage.value = '';
    final fullPhone = '+91$phone';

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        errorMessage.value = e.message ?? 'Verification failed';
      },
      codeSent: (String vId, int? resendToken) {
        verificationId.value = vId;
        isLoading.value = false;
        _startResendTimer();
        Get.toNamed(AppRoutes.otpVerify);
      },
      codeAutoRetrievalTimeout: (String vId) {
        verificationId.value = vId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> verifyOtp(String otp, {String? displayName}) async {
    if (verificationId.value.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;

      // Check if new user
      final doc = await _db.collection(AppConstants.colUsers).doc(user.uid).get();
      if (!doc.exists) {
        // Create profile
        final newUser = UserModel(
          uid: user.uid,
          phone: user.phoneNumber ?? '',
          name: displayName ?? '',
          createdAt: DateTime.now(),
          groupRoles: {},
        );
        await _db.collection(AppConstants.colUsers).doc(user.uid).set(newUser.toMap());
        currentUser.value = newUser;

        // Check if phone matches any team's owner or player
        await _linkPhoneToExistingEntities(user.uid, user.phoneNumber ?? '');
      } else {
        currentUser.value = UserModel.fromMap(doc.data()!, user.uid);
        await _linkPhoneToExistingEntities(user.uid, user.phoneNumber ?? '');
      }

      await resolveNavigation();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Invalid OTP';
    } finally {
      isLoading.value = false;
    }
  }

  /// When a user logs in, link them to groups where their phone is registered
  Future<void> _linkPhoneToExistingEntities(String uid, String fullPhone) async {
    // Normalize: remove +91
    final phone = fullPhone.replaceAll('+91', '').trim();

    // Find groups where this phone is a team owner
    final teamsQuery = await _db.collection(AppConstants.colTeams).where('ownerPhone', isEqualTo: phone).get();

    for (final teamDoc in teamsQuery.docs) {
      final team = TeamModel.fromMap(teamDoc.data(), teamDoc.id);
      if (team.ownerUid.isEmpty) {
        // Link owner UID
        await teamDoc.reference.update({'ownerUid': uid});

        // Add role to user
        await _db.collection(AppConstants.colUsers).doc(uid).update({
          'groupRoles.${team.groupId}': AppConstants.roleOwner,
        });

        // Refresh local
        currentUser.value = currentUser.value?.copyWith(
          groupRoles: {
            ...currentUser.value!.groupRoles,
            team.groupId: AppConstants.roleOwner,
          },
        );
      }
    }

    // Find groups where this phone is a player
    final playersQuery = await _db.collection(AppConstants.colPlayers).where('phone', isEqualTo: phone).get();

    for (final playerDoc in playersQuery.docs) {
      final player = PlayerModel.fromMap(playerDoc.data(), playerDoc.id);
      if (player.uid.isEmpty) {
        await playerDoc.reference.update({'uid': uid});

        // Only add player role if not already admin/owner
        final existingRole = currentUser.value?.groupRoles[player.groupId] ?? '';
        if (existingRole.isEmpty) {
          await _db.collection(AppConstants.colUsers).doc(uid).update({
            'groupRoles.${player.groupId}': AppConstants.rolePlayer,
          });
          currentUser.value = currentUser.value?.copyWith(
            groupRoles: {
              ...currentUser.value!.groupRoles,
              player.groupId: AppConstants.rolePlayer,
            },
          );
        }
      }
    }
  }

  // ── Profile Update ───────────────────────────────────────────────────────

  Future<void> updateName(String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection(AppConstants.colUsers).doc(uid).update({'name': name});
    currentUser.value = currentUser.value?.copyWith(name: name);
  }

  Future<void> updatePhoto(String photoUrl) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection(AppConstants.colUsers).doc(uid).update({'photoUrl': photoUrl});
    currentUser.value = currentUser.value?.copyWith(photoUrl: photoUrl);

    // Also update any player record linked to this uid
    final phone = currentUser.value?.phone.replaceAll('+91', '') ?? '';
    final playersQuery = await _db.collection(AppConstants.colPlayers).where('uid', isEqualTo: uid).get();
    for (final doc in playersQuery.docs) {
      await doc.reference.update({'photoUrl': photoUrl});
    }
  }

  Future<void> saveFcmToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection(AppConstants.colUsers).doc(uid).update({'fcmToken': token});
  }

  void signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefCurrentGroupId);
    currentUser.value = null;
    currentGroupId.value = '';
    currentRole.value = '';
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool get isLoggedIn => _auth.currentUser != null;
  String get uid => _auth.currentUser?.uid ?? '';
  String get phone => (_auth.currentUser?.phoneNumber ?? '').replaceAll('+91', '').trim();

  void _startResendTimer() {
    resendSeconds.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
        return true;
      }
      return false;
    });
  }
}
