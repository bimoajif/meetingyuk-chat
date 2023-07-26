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

class ChatController extends GetxController {
  // --------------------------------------------------------------
  // Define local variables
  // --------------------------------------------------------------
  final String endpoint =
      'http://10.73.214.182:3001'; // Change this to valid endpoint
  final Dio dio = Dio();
  final e2ee = E2EE_AES();
  final e2eersa = E2EE_RSA();
  GetStorage box = GetStorage();
  late AuthController ctrl;
  Timer? chatUpdateTimer;
  Timer? messageUpdateTimer;

  // --------------------------------------------------------------
  // Initial run start listing chatRooms
  // --------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    ctrl = Get.find();
    startChatUpdates(ctrl.currentUser.value.userId.toHexString());
  }

  // --------------------------------------------------------------
  // Create a local variable to store chatRooms, messages,
  // selectedMessage, receiverUser, selectedRoom
  // --------------------------------------------------------------
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;
  RxList<MessageModel> messageList = <MessageModel>[].obs;
  RxString selectedMessage = ''.obs;

  Rx<UserChatRoom> receiverUser = UserChatRoom(
    userId: '',
    name: '',
    profilePic: '',
    roomKey: '',
  ).obs;

  Rx<ChatRoomModel> selectedRoom = ChatRoomModel(
    chatId: '',
    lastMessage: '',
    users: [],
    roomKey: '',
    timesent: '',
  ).obs;
  

  // --------------------------------------------------------------
  // Function to start updating list of chatRooms
  // --------------------------------------------------------------
  void startChatUpdates(String id) {
    chatUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getChat(id);
    });
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

  // --------------------------------------------------------------
  // Function to start updating list of messages
  // --------------------------------------------------------------
  void startMessageUpdates(RxString id) {
    messageUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      getMessage(id);
    });
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

  // --------------------------------------------------------------
  // Function to initiate chat with merchant or user
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // Function to select a chat from list
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // Function to save sent message to "chats" collection
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // Function to save sent message to "message" collection
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // Function to send text message
  // --------------------------------------------------------------
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
}
