// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chat/common/enums/message_enum.dart';
import 'package:realtime_chat/common/utils/aes_encryption.dart';
import 'package:realtime_chat/common/utils/rsa_encryption.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/models/chat_room_model.dart';
import 'package:realtime_chat/models/message_model.dart';

class ChatController extends GetxController {
  // The endpoint url for the chat API
  final String CHAT_ENDPOINT_URL =
      dotenv.get('CHAT_ENDPOINT_URL', fallback: "URL NOT FOUND");

  // The HTTP client for making requests to endpoint
  final Dio dio = Dio();

  final e2ee = E2EE_AES();
  final e2eersa = E2EE_RSA();

  // Local storage for storing user data and other persistent data
  GetStorage box = GetStorage();

  // Authentication controller for accessing user data
  late AuthController ctrl;

  // Timer for updating chats and messages
  Timer? chatUpdateTimer;
  Timer? messageUpdateTimer;

  @override
  void onInit() {
    super.onInit();

    // Get the instance of the AuthController
    ctrl = Get.find();

    // Start periodic updates for the chat
    startChatUpdates(ctrl.currentUser.value.userId);
  }

  // Observable list of chat rooms
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;

  // Observable list of messages
  RxList<MessageModel> messageList = <MessageModel>[].obs;

  // Observable for the currently selected message
  RxString selectedRoomId = ''.obs;

  // Observable for the user we're currently chatting with
  Rx<UserChatRoom> receiverUser = UserChatRoom(
    userId: '',
    name: '',
    profilePic: '',
    roomKey: '',
  ).obs;

  // Observable for the currently selected chat room
  Rx<ChatRoomModel> selectedRoom = ChatRoomModel(
    chatId: '',
    lastMessage: '',
    users: [],
    roomKey: '',
    timesent: '',
  ).obs;

  // Starts a periodic task to update the chat rooms
  void startChatUpdates(String id) {
    chatUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getChat(id);
    });
  }

  // Fetches the list of chat rooms for the given user ID
  Stream<List<ChatRoomModel>> getChat(String id) {
    StreamController<List<ChatRoomModel>> streamController = StreamController();

    dio.get('$CHAT_ENDPOINT_URL/chat/$id').then((response) {
      if (response.statusCode == 200) {
        List<dynamic> chatRoomData = response.data;
        List<ChatRoomModel> chatRooms =
            chatRoomData.map((data) => ChatRoomModel.fromJson(data)).toList();

        chatRooms.sort((b, a) => a.timesent.compareTo(b.timesent));

        if (!listEquals(chatRooms, chatRoomList)) {
          chatRoomList.assignAll(chatRooms);
        }

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

  // Starts a periodic task to update the messages for the given chat room ID
  void startMessageUpdates(RxString id) {
    messageUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      getMessage(id);
    });
  }

  // Fetches the list of messages for the given chat room ID
  Stream<List<MessageModel>> getMessage(RxString id) {
    StreamController<List<MessageModel>> streamController = StreamController();

    dio.get('$CHAT_ENDPOINT_URL/message/$id').then((response) {
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

  // Initializes a chat with the given user
  void initiateChat(
    String userId,
    String name,
    String profilePic,
    String userPublicKey,
    String recipientPublicKey,
  ) async {
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

    // data that saved when initialize chat with other user
    var roomData = {
      "lastMessage": "",
      "timesent": timeSent,
      "users": [
        {
          "userId": ctrl.currentUser.value.userId,
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
    };
    try {
      await dio.post('$CHAT_ENDPOINT_URL/chat', data: roomData);
    } catch (e) {
      rethrow;
    }
  }

  // Selects a chat room and loads its messages
  void selectChat(
    String chatId,
    String userId,
    String name,
    String profilePic,
    String roomKey,
  ) {
    final privateKey = box.read('priv_key');
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
    selectedRoomId.value = chatId;
    receiverUser.value = UserChatRoom(
      userId: userId,
      name: name,
      profilePic: profilePic,
      roomKey: '',
    );
  }

  // Check if there are already chat room with selected user
  Future<Map<String, dynamic>> getChatId(String user2) async {
    String? foundChatId;
    String? foundRoomKey;

    try {
      final response = await dio.get('$CHAT_ENDPOINT_URL/chat');
      List<dynamic> chatList = response.data;

      for (var chat in chatList) {
        List<dynamic> users = chat['users'];

        bool foundUser1 = false;
        String tempRoomKey = '';
        for (var user in users) {
          if (user['username'] == ctrl.currentUser.value.name) {
            foundUser1 = true;
            tempRoomKey = user['roomKey'];
          }
        }

        bool foundUser2 = users.any((user) => user['username'] == user2);

        if (foundUser1 && foundUser2) {
          foundChatId = chat['_id'];
          foundRoomKey = tempRoomKey;
          break; // Exit the loop once both users are found in a chat
        }
      }
    } catch (error) {
      return {'chatId': 'ERROR', 'roomKey': 'ERROR'};
    }

    return {
      'chatId': foundChatId ?? 'NOT FOUND',
      'roomKey': foundRoomKey ?? 'NOT FOUND'
    };
  }

  // Saves a new message to the chat room collection
  void saveDataToChat(
    String chatId,
    String text,
    String timesent,
  ) async {
    try {
      await dio.put('$CHAT_ENDPOINT_URL/chat/$chatId',
          data: {"text": text, "timesent": timesent});
    } catch (e) {
      rethrow;
    }
  }

  // Saves a new message to the message collection
  void saveDataToMessage(
    String chatId,
    String message,
    String receiverId,
    String senderId,
    String timesent,
    String iv,
    MessageEnum type,
  ) async {
    var messageData = {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': message,
      'type': type.type,
      'timesent': timesent,
      'iv': iv,
    };
    try {
      await dio.post('$CHAT_ENDPOINT_URL/message', data: messageData);
    } catch (e) {
      rethrow;
    }
  }

  // Function to send text message
  void sendTextMessage({
    required String text,
    required String chatId,
    required String receiverId,
    required String roomKey,
  }) async {
    final keypair = e2ee.generateAESKey();
    final iv = keypair.iv;
    final encryptedText = e2ee.encrypter(roomKey, iv, text);
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String timeSent = dateFormat.format(DateTime.now());
    saveDataToMessage(
      chatId,
      encryptedText,
      receiverId,
      ctrl.currentUser.value.userId,
      timeSent,
      iv,
      MessageEnum.TEXT,
    );
    saveDataToChat(chatId, text, timeSent);
  }

  void sendBroadcastMessage({
    required String text,
    required List chatId,
    required List receiverId,
    required List roomKey,
  }) {
    final privateKey = box.read('priv_key');
    final senderPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(addHeaderFooter(
      privateKey,
      false,
    ));
    try {
      for (var i = 0; i < chatId.length; i++) {
        final decryptedRoomKey =
            e2eersa.decrypter(senderPrivateKey, roomKey[i]);
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
