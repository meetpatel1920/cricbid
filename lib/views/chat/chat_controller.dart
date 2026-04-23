import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricbid/models/message_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/app_consts.dart';

import '../auth/auth_controller.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController _authCtrl = Get.find<AuthController>();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;

  String get _groupId => _authCtrl.currentGroupId.value;

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  void _listenToMessages() {
    if (_groupId.isEmpty) return;
    _db
        .collection(AppConsts.colMessages)
        .where('groupId', isEqualTo: _groupId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('sentAt', descending: false)
        .limitToLast(200)
        .snapshots()
        .listen((snap) {
      messages.value = snap.docs.map((d) => MessageModel.fromMap(d.data(), d.id)).toList();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final user = _authCtrl.currentUser.value;
    if (user == null) return;

    final msgId = const Uuid().v4();
    final msg = MessageModel(
      id: msgId,
      groupId: _groupId,
      senderUid: user.uid,
      senderName: user.name,
      senderPhotoUrl: user.photoUrl,
      senderRole: _authCtrl.currentRole.value,
      text: text.trim(),
      sentAt: DateTime.now(),
    );

    await _db.collection(AppConsts.colMessages).doc(msgId).set(msg.toMap());
  }

  Future<void> deleteMessage(String msgId) async {
    await _db.collection(AppConsts.colMessages).doc(msgId).update({'isDeleted': true});
  }
}
