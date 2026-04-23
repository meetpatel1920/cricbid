// ignore_for_file: unused_import
import 'package:cricbid/models/player_model.dart';
import 'package:cricbid/models/team_model.dart';
import 'package:cricbid/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/consts/app_consts.dart';
import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';

class AuthController extends GetxController {
  // ── Firebase (kept for future use — currently bypassed in OTP flow) ────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // ──────────────────────────────────────────────────────────────────────────

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString verificationId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentGroupId = ''.obs;
  final RxString currentRole = ''.obs;

  // OTP timer
  final RxInt resendSeconds = 0.obs;

  // Dev: stores last phone for mock verify
  String _pendingPhone = '';

  @override
  void onInit() {
    super.onInit();
    _loadSavedGroup();
    // Listen to real firebase auth state for future use
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _loadSavedGroup() async {
    final prefs = await SharedPreferences.getInstance();
    currentGroupId.value = prefs.getString(AppConsts.prefCurrentGroupId) ?? '';
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    // Real firebase auth listener — active when Firebase OTP is enabled
    if (firebaseUser == null) return;
    await _loadUserProfile(firebaseUser.uid);
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection(AppConsts.colUsers).doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data()!, uid);
        await resolveNavigation();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile';
    }
  }

  Future<void> resolveNavigation() async {
    final user = currentUser.value;
    if (user == null) return;

    final groups = user.groupRoles;
    if (groups.isEmpty) {
      Get.offAllNamed(AppRoutes.noGroup);
      return;
    }

    String groupId = currentGroupId.value;
    if (groupId.isEmpty || !groups.containsKey(groupId)) {
      groupId = groups.keys.first;
    }

    NotificationService.instance.listenForPersonalNotifications(user.uid);
    NotificationService.instance.listenForGroupNotifications(groupId);

    await setCurrentGroup(groupId);
  }

  Future<void> setCurrentGroup(String groupId) async {
    final user = currentUser.value;
    if (user == null) return;

    currentGroupId.value = groupId;
    currentRole.value = user.groupRoles[groupId] ?? AppConsts.rolePlayer;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConsts.prefCurrentGroupId, groupId);

    switch (currentRole.value) {
      case AppConsts.roleAdmin:
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case AppConsts.roleOwner:
        Get.offAllNamed(AppRoutes.ownerDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.playerDashboard);
    }
  }

  // ── Phone Login — Mock OTP flow ───────────────────────────────────────────
  /// Sends OTP. In dev mode, accepts any phone and uses "123456" as OTP.
  Future<void> sendOtp(String phone) async {
    isLoading.value = true;
    errorMessage.value = '';

    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    _pendingPhone = phone;
    _startResendTimer();
    isLoading.value = false;
    Get.toNamed(AppRoutes.otpVerify);

    // ── Firebase OTP (enable when paid Firebase is ready) ────────────────
    // final fullPhone = '+91$phone';
    // await _auth.verifyPhoneNumber(
    //   phoneNumber: fullPhone,
    //   verificationCompleted: (PhoneAuthCredential credential) async {
    //     await _auth.signInWithCredential(credential);
    //   },
    //   verificationFailed: (FirebaseAuthException e) {
    //     isLoading.value = false;
    //     errorMessage.value = e.message ?? 'Verification failed';
    //   },
    //   codeSent: (String vId, int? resendToken) {
    //     verificationId.value = vId;
    //     isLoading.value = false;
    //     _startResendTimer();
    //     Get.toNamed(AppRoutes.otpVerify);
    //   },
    //   codeAutoRetrievalTimeout: (String vId) {
    //     verificationId.value = vId;
    //   },
    //   timeout: const Duration(seconds: 60),
    // );
    // ─────────────────────────────────────────────────────────────────────
  }

  /// Verifies OTP. In dev mode, "123456" always passes for any phone.
  Future<void> verifyOtp(String otp, {String? displayName}) async {
    isLoading.value = true;
    errorMessage.value = '';

    await Future.delayed(const Duration(milliseconds: 700)); // simulate network

    // ── Dev mock verification ──────────────────────────────────────────────
    if (otp != AppConsts.devOtp) {
      errorMessage.value = 'Invalid OTP. Use ${AppConsts.devOtp}';
      isLoading.value = false;
      return;
    }

    // Mock user — load from Firestore by phone if exists, else create
    try {
      final phone = _pendingPhone;
      final query = await _db.collection(AppConsts.colUsers).where('phone', isEqualTo: '+91$phone').limit(1).get();

      UserModel user;
      if (query.docs.isEmpty) {
        // New user: create mock uid from phone
        final uid = 'dev_${phone}_uid';
        user = UserModel(
          uid: uid,
          phone: '+91$phone',
          name: displayName ?? '',
          createdAt: DateTime.now(),
          groupRoles: {},
        );
        await _db.collection(AppConsts.colUsers).doc(uid).set(user.toMap());
        await _linkPhoneToExistingEntities(uid, '+91$phone');
      } else {
        final doc = query.docs.first;
        user = UserModel.fromMap(doc.data(), doc.id);
        await _linkPhoneToExistingEntities(user.uid, '+91$phone');
      }

      currentUser.value = user;
      await resolveNavigation();
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
    } finally {
      isLoading.value = false;
    }

    // ── Firebase OTP verify (enable when paid Firebase is ready) ──────────
    // if (verificationId.value.isEmpty) return;
    // try {
    //   final credential = PhoneAuthProvider.credential(
    //     verificationId: verificationId.value,
    //     smsCode: otp,
    //   );
    //   final result = await _auth.signInWithCredential(credential);
    //   final user = result.user!;
    //   final doc = await _db.collection(AppConsts.colUsers).doc(user.uid).get();
    //   if (!doc.exists) {
    //     final newUser = UserModel(
    //       uid: user.uid,
    //       phone: user.phoneNumber ?? '',
    //       name: displayName ?? '',
    //       createdAt: DateTime.now(),
    //       groupRoles: {},
    //     );
    //     await _db.collection(AppConsts.colUsers).doc(user.uid).set(newUser.toMap());
    //     currentUser.value = newUser;
    //     await _linkPhoneToExistingEntities(user.uid, user.phoneNumber ?? '');
    //   } else {
    //     currentUser.value = UserModel.fromMap(doc.data()!, user.uid);
    //     await _linkPhoneToExistingEntities(user.uid, user.phoneNumber ?? '');
    //   }
    //   await resolveNavigation();
    // } on FirebaseAuthException catch (e) {
    //   errorMessage.value = e.message ?? 'Invalid OTP';
    // } finally {
    //   isLoading.value = false;
    // }
    // ─────────────────────────────────────────────────────────────────────
  }

  Future<void> _linkPhoneToExistingEntities(String uid, String fullPhone) async {
    final phone = fullPhone.replaceAll('+91', '').trim();

    final teamsQuery = await _db.collection(AppConsts.colTeams).where('ownerPhone', isEqualTo: phone).get();

    for (final teamDoc in teamsQuery.docs) {
      final team = TeamModel.fromMap(teamDoc.data(), teamDoc.id);
      if (team.ownerUid.isEmpty) {
        await teamDoc.reference.update({'ownerUid': uid});
        await _db.collection(AppConsts.colUsers).doc(uid).update({
          'groupRoles.${team.groupId}': AppConsts.roleOwner,
        });
        currentUser.value = currentUser.value?.copyWith(
          groupRoles: {
            ...currentUser.value!.groupRoles,
            team.groupId: AppConsts.roleOwner,
          },
        );
      }
    }

    final playersQuery = await _db.collection(AppConsts.colPlayers).where('phone', isEqualTo: phone).get();

    for (final playerDoc in playersQuery.docs) {
      final player = PlayerModel.fromMap(playerDoc.data(), playerDoc.id);
      if (player.uid.isEmpty) {
        await playerDoc.reference.update({'uid': uid});
        final existingRole = currentUser.value?.groupRoles[player.groupId] ?? '';
        if (existingRole.isEmpty) {
          await _db.collection(AppConsts.colUsers).doc(uid).update({
            'groupRoles.${player.groupId}': AppConsts.rolePlayer,
          });
          currentUser.value = currentUser.value?.copyWith(
            groupRoles: {
              ...currentUser.value!.groupRoles,
              player.groupId: AppConsts.rolePlayer,
            },
          );
        }
      }
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  Future<void> updateName(String name) async {
    final uid = _auth.currentUser?.uid ?? currentUser.value?.uid;
    if (uid == null) return;
    await _db.collection(AppConsts.colUsers).doc(uid).update({'name': name});
    currentUser.value = currentUser.value?.copyWith(name: name);
  }

  Future<void> updatePhoto(String photoUrl) async {
    final uid = _auth.currentUser?.uid ?? currentUser.value?.uid;
    if (uid == null) return;
    await _db.collection(AppConsts.colUsers).doc(uid).update({'photoUrl': photoUrl});
    currentUser.value = currentUser.value?.copyWith(photoUrl: photoUrl);
  }

  Future<void> saveFcmToken(String token) async {
    final uid = _auth.currentUser?.uid ?? currentUser.value?.uid;
    if (uid == null) return;
    await _db.collection(AppConsts.colUsers).doc(uid).update({'fcmToken': token});
  }

  void signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConsts.prefCurrentGroupId);
    currentUser.value = null;
    currentGroupId.value = '';
    currentRole.value = '';
    _pendingPhone = '';
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool get isLoggedIn => currentUser.value != null || _auth.currentUser != null;

  String get uid => currentUser.value?.uid ?? _auth.currentUser?.uid ?? '';

  String get phone => _pendingPhone.isNotEmpty ? _pendingPhone : (_auth.currentUser?.phoneNumber ?? '').replaceAll('+91', '').trim();

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
