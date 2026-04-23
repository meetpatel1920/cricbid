import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/app_consts.dart';
import '../../models/app_models.dart';
import '../auth/auth_controller.dart';

class PlayerController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final AuthController _authCtrl = Get.find<AuthController>();

  final RxList<PlayerModel> players = <PlayerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authCtrl.currentGroupId, (_) => loadPlayers());
    loadPlayers();
  }

  String get _groupId => _authCtrl.currentGroupId.value;

  Stream<List<PlayerModel>> streamPlayers(String groupId) {
    return _db
        .collection(AppConsts.colPlayers)
        .where('groupId', isEqualTo: groupId)
        .orderBy('playerNumber')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PlayerModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> loadPlayers() async {
    if (_groupId.isEmpty) return;
    isLoading.value = true;
    try {
      final snap = await _db
          .collection(AppConsts.colPlayers)
          .where('groupId', isEqualTo: _groupId)
          .orderBy('playerNumber')
          .get();
      players.value =
          snap.docs.map((d) => PlayerModel.fromMap(d.data(), d.id)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> _nextPlayerNumber() async {
    final snap = await _db
        .collection(AppConsts.colPlayers)
        .where('groupId', isEqualTo: _groupId)
        .orderBy('playerNumber', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 1;
    return (PlayerModel.fromMap(snap.docs.first.data(), snap.docs.first.id)
                .playerNumber) +
        1;
  }

  // ── Add Single Player ────────────────────────────────────────────────────

  Future<void> addPlayer({
    required String name,
    required String phone,
    String? address,
    DateTime? birthdate,
    required String type,
    String? lastTeam,
    String? photoUrl,
    String? imageLocalPath,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final playerId = const Uuid().v4();
      int number = await _nextPlayerNumber();

      String? finalPhotoUrl = photoUrl;

      // Upload image if local path provided
      if (imageLocalPath != null && imageLocalPath.isNotEmpty) {
        finalPhotoUrl = await _uploadImage(imageLocalPath, playerId);
      }

      final player = PlayerModel(
        id: playerId,
        groupId: _groupId,
        name: name.trim(),
        phone: phone.trim(),
        address: address,
        birthdate: birthdate,
        type: type,
        lastTeam: lastTeam,
        photoUrl: finalPhotoUrl,
        playerNumber: number,
        auctionStatus: AppConsts.playerStatusPending,
        createdAt: DateTime.now(),
      );

      await _db
          .collection(AppConsts.colPlayers)
          .doc(playerId)
          .set(player.toMap());

      // Check if user already exists with this phone
      final userQuery = await _db
          .collection(AppConsts.colUsers)
          .where('phone', isEqualTo: '+91${phone.trim()}')
          .get();
      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        await _db
            .collection(AppConsts.colPlayers)
            .doc(playerId)
            .update({'uid': userDoc.id});
        final existingRole =
            (userDoc.data()['groupRoles'] as Map?)
                ?[_groupId] ??
                '';
        if (existingRole.isEmpty) {
          await userDoc.reference.update({
            'groupRoles.$_groupId': AppConsts.rolePlayer,
          });
        }
      }

      players.add(player);
      Get.back();
      Get.snackbar('Success', '${name} added as player #$number');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Bulk Import from Excel ───────────────────────────────────────────────

  Future<void> importPlayersFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) return;

      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first]!;

      isLoading.value = true;
      int added = 0;

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty || row[AppConsts.excelPlayerName]?.value == null)
          continue;

        final name =
            row[AppConsts.excelPlayerName]?.value?.toString().trim() ?? '';
        final phone =
            row[AppConsts.excelPlayerPhone]?.value?.toString().trim() ?? '';
        final type =
            row[AppConsts.excelPlayerType]?.value?.toString().trim() ??
                AppConsts.typeBatting;
        final imageUrl =
            row[AppConsts.excelPlayerImageUrl]?.value?.toString().trim();

        if (name.isEmpty || phone.isEmpty) continue;

        await addPlayer(
          name: name,
          phone: phone,
          address:
              row[AppConsts.excelPlayerAddress]?.value?.toString(),
          type: type,
          lastTeam:
              row[AppConsts.excelPlayerLastTeam]?.value?.toString(),
          photoUrl: imageUrl,
        );
        added++;
      }

      Get.snackbar('Import Complete', '$added players imported');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Image Upload ─────────────────────────────────────────────────────────

  Future<String?> _uploadImage(String localPath, String playerId) async {
    try {
      isUploading.value = true;
      final file = File(localPath);
      final ref = _storage
          .ref()
          .child(AppConsts.storagePlayerImages)
          .child('$playerId.jpg');
      final task = ref.putFile(file);
      task.snapshotEvents.listen((event) {
        uploadProgress.value =
            event.bytesTransferred / event.totalBytes;
      });
      await task;
      return await ref.getDownloadURL();
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0;
    }
  }

  /// Pick image from gallery or camera, upload, return URL
  Future<String?> pickAndUploadImage(
      {required String playerId, bool fromCamera = false}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image == null) return null;
    return await _uploadImage(image.path, playerId);
  }

  // ── Update Player Photo ──────────────────────────────────────────────────

  Future<void> updatePlayerPhoto(String playerId, String photoUrl) async {
    await _db
        .collection(AppConsts.colPlayers)
        .doc(playerId)
        .update({'photoUrl': photoUrl});
    final idx = players.indexWhere((p) => p.id == playerId);
    if (idx != -1) {
      players[idx] = players[idx].copyWith(photoUrl: photoUrl);
    }
  }

  // ── Get Players by status ────────────────────────────────────────────────

  List<PlayerModel> get unsoldPlayers => players
      .where((p) =>
          p.auctionStatus == AppConsts.playerStatusUnsold ||
          p.auctionStatus == AppConsts.playerStatusSkipped ||
          p.auctionStatus == AppConsts.playerStatusPending)
      .toList();

  List<PlayerModel> get soldPlayers => players
      .where((p) => p.auctionStatus == AppConsts.playerStatusSold)
      .toList();

  PlayerModel? getPlayerByNumber(int number) {
    try {
      return players.firstWhere((p) => p.playerNumber == number);
    } catch (_) {
      return null;
    }
  }

  List<PlayerModel> getPlayersForTeam(String teamId) =>
      players.where((p) => p.teamId == teamId).toList();
}
