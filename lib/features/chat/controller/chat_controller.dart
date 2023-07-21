import 'dart:async';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:realtime_chat/common/enums/message_enum.dart';
import 'package:realtime_chat/common/utils/aes_encryption.dart';
import 'package:realtime_chat/common/utils/rsa_encryption.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/models/chat_room_model.dart';
import 'package:realtime_chat/models/message_model.dart';
import 'package:realtime_chat/models/product_model.dart';

class ChatController extends GetxController {
  final String endpoint = 'http://10.73.176.155:3001';
  final Dio dio = Dio();
  final e2ee = E2EE_AES();
  final e2eersa = E2EE_RSA();
  GetStorage box = GetStorage();
  late AuthController ctrl;
  Timer? chatUpdateTimer;
  Timer? messageUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    ctrl = Get.find();
    startChatUpdates(ctrl.currentUser.value.userId.toHexString());
  }

  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;
  RxList<MessageModel> messageList = <MessageModel>[].obs;
  RxString selectedMessage = ''.obs;

  Rx<UserChatRoom> receiverUser =
      UserChatRoom(userId: '', name: '', profilePic: '', roomKey: '').obs;

  Rx<ChatRoomModel> selectedRoom = ChatRoomModel(
    chatId: '',
    lastMessage: '',
    users: [],
    roomKey: '',
    timesent: '',
  ).obs;

  void startChatUpdates(String id) {
    chatUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getChat(id);
    });
  }

  void startMessageUpdates(RxString id) {
    messageUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      getMessage(id);
    });
  }

  void updateIsSeen(String chatId, String receiverId) async {
    await db.open();
    var collection = db.collection('chats');
    try {
      await collection.updateOne(
          where
              .eq('_id', ObjectId.fromHexString(chatId))
              .and(where.eq('users.userId', receiverId)),
          modify.set('users.\$[].isSeen.', false));
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ChatRoomModel>> getChat(String id) {
    StreamController<List<ChatRoomModel>> streamController = StreamController();

    dio.get('$endpoint/chat/$id').then((response) {
      if (response.statusCode == 200) {
        List<dynamic> chatRoomData = response.data;
        List<ChatRoomModel> chatRooms =
            chatRoomData.map((data) => ChatRoomModel.fromJson(data)).toList();
        chatRoomList.value = chatRooms;
        streamController.add(chatRooms);
        streamController.close();
      } else {
        streamController.addError('Failed to fetch chat data');
      }
    }).catchError((error) {
      streamController.addError('Failed to fetch chat data: $error');
    });
    // print(chatRoomList.length);
    return streamController.stream;
  }

  Stream<List<MessageModel>> getMessage(RxString id) {
    StreamController<List<MessageModel>> streamController = StreamController();

    dio.get('$endpoint/message/$id').then((response) {
      if (response.statusCode == 200) {
        List<dynamic> messageData = response.data;
        List<MessageModel> messages =
            messageData.map((data) => MessageModel.fromJson(data)).toList();

        messages.sort((a, b) => a.timesent.compareTo(b.timesent));

        if (!listEquals(messages, messageList)) {
          messageList.assignAll(messages);
        }

        messageList.value = messages;

        streamController.add(messages);

        streamController.close();
      } else {
        streamController.addError('Failed to fetch message data');
      }
    }).catchError((error) {
      streamController.addError('Failed to fetch message data: $error');
    });

    return streamController.stream;
  }

  Future<ProductModel> getProduct(String id) {
    return dio.get('$endpoint/product/$id').then((response) {
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch product');
      }
    });
  }

  void initiateChat(String userId, String name, String profilePic,
      String userPublicKey, String recipientPublicKey) async {
    final key = e2ee.generateAESKey();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String timeSent = dateFormat.format(DateTime.now());
    final userPublicKeyPEM = CryptoUtils.rsaPublicKeyFromPem(addHeaderFooter(
      userPublicKey,
      true,
    ));
    final recipientPublicKeyPEM = CryptoUtils.rsaPublicKeyFromPem(
      addHeaderFooter(
        recipientPublicKey,
        true,
      ),
    );
    final userRoomKey = e2eersa.encrypter(userPublicKeyPEM, key.key);
    final recipientRoomKey = e2eersa.encrypter(recipientPublicKeyPEM, key.key);

    var roomData = {
      "lastMessage": "",
      "timesent": timeSent,
      "users": [
        {
          "userId": ctrl.currentUser.value.userId.toHexString(),
          "username": ctrl.currentUser.value.name,
          "profilePic": ctrl.currentUser.value.profilePic,
          "roomKey": userRoomKey,
          "isSeen": true,
        },
        {
          "userId": userId,
          "username": name,
          "profilePic": profilePic,
          "roomKey": recipientRoomKey,
          "isSeen": true,
        }
      ],
      "roomKey": key.key,
    };
    try {
      await dio.post('$endpoint/chat', data: roomData);
    } catch (e) {
      rethrow;
    }
  }

  void selectChat(
    String chatId,
    String userId,
    String name,
    String profilePic,
    String roomKey,
  ) {
    final privateKey =
        box.read('${ctrl.currentUser.value.userId.toHexString()}_key');
    final senderPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(addHeaderFooter(
      privateKey,
      false,
    ));
    final decryptedRoomKey = e2eersa.decrypter(senderPrivateKey, roomKey);
    selectedRoom.value = ChatRoomModel(
      chatId: chatId,
      lastMessage: '',
      users: [],
      roomKey: decryptedRoomKey,
      timesent: '',
    );
    selectedMessage.value = chatId;
    receiverUser.value = UserChatRoom(
      userId: userId,
      name: name,
      profilePic: profilePic,
      roomKey: '',
    );
  }

  void saveDataToChat(
    String receiverId,
    String chatId,
    String text,
  ) async {
    var collection = db.collection('chats');
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String timeSent = dateFormat.format(DateTime.now());
    try {
      collection.updateOne(where.eq('_id', ObjectId.fromHexString(chatId)),
          modify.set('lastMessage', text));
      collection.updateOne(where.eq('_id', ObjectId.fromHexString(chatId)),
          modify.set('timesent', timeSent));
      // print(chatId);
      // await dio.put('$endpoint/$chatId', data: {'lastMessage': text});
    } catch (e) {
      rethrow;
    }
  }

  void saveDataToMessage(
    String chatId,
    String message,
    String receiverId,
    String senderId,
    String iv,
    MessageEnum type,
  ) async {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String timeSent = dateFormat.format(DateTime.now());
    var messageData = {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': message,
      'type': type.type,
      'timesent': timeSent,
      'iv': iv,
    };
    try {
      await dio.post('$endpoint/message', data: messageData);
    } catch (e) {
      rethrow;
    }
  }

  void sendTextMessage({
    required String text,
    required String chatId,
    required String receiverId,
    required String roomKey,
  }) async {
    final keypair = e2ee.generateAESKey();
    final iv = keypair.iv;
    final encryptedText = e2ee.encrypter(roomKey, iv, text);
    saveDataToMessage(
      chatId,
      encryptedText,
      receiverId,
      ctrl.currentUser.value.userId.toHexString(),
      iv,
      MessageEnum.TEXT,
    );
    saveDataToChat(receiverId, chatId, text);
  }

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
        final decryptedRoomKey = e2eersa.decrypter(senderPrivateKey, roomKey[i]);
        sendTextMessage(
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
