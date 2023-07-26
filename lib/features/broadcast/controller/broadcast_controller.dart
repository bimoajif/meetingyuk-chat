import 'package:basic_utils/basic_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realtime_chat/common/utils/aes_encryption.dart';
import 'package:realtime_chat/common/utils/rsa_encryption.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';

class BroadcastController extends GetxController  {
  GetStorage box = GetStorage();
  late AuthController ctrl;
  late ChatController controller;
  final e2ee = E2EE_AES();
  final e2eersa = E2EE_RSA();

  // --------------------------------------------------------------
  // Function to send broadcast message
  // --------------------------------------------------------------
  void sendBroadcastMessage({
    required String text,
    required List chatId,
    required List receiverId,
    required List roomKey,
  }) {
    final privateKey =
        box.read('${ctrl.currentUser.value.userId.toHexString()}_key');
    final senderPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(addHeaderFooter(
      privateKey,
      false,
    ));
    try {
      for (var i = 0; i < chatId.length; i++) {
        final decryptedRoomKey =
            e2eersa.decrypter(senderPrivateKey, roomKey[i]);
        controller.sendTextMessage(
          text: text,
          chatId: chatId[i],
          receiverId: receiverId[i],
          roomKey: decryptedRoomKey,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}