import 'dart:async';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:realtime_chat/common/enums/message_enum.dart';
import 'package:realtime_chat/common/utils/address.dart';
import 'package:realtime_chat/common/utils/aes_encryption.dart';
import 'package:realtime_chat/common/utils/rsa_encryption.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/models/chat_room_model.dart';
import 'package:realtime_chat/models/message_model.dart';

class ChatController extends GetxController {
  // The endpoint for the chat API
  final String endpoint = ENDPOINT_URL;

  // The HTTP client for making requests
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
  RxString selectedMessage = ''.obs;

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

  // Initializes a chat with the given user
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
      "roomKey": key.key,
    };
    try {
      await dio.post('$endpoint/chat', data: roomData);
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
    final privateKey = box.read('${ctrl.currentUser.value.userId}_key');
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

  // Saves a new message to the chat room collection
  void saveDataToChat(
    String receiverId,
    String chatId,
    String text,
  ) async {
    var collection = db.collection('chats');
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String timeSent = dateFormat.format(DateTime.now());
    try {
      // collection.updateOne(where.eq('_id', ObjectId.fromHexString(chatId)),
      //     modify.set('lastMessage', text));
      // collection.updateOne(where.eq('_id', ObjectId.fromHexString(chatId)),
      //     modify.set('timesent', timeSent));
      await dio.put('$endpoint/chat/$chatId', data: {"text": text});
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
    saveDataToMessage(
      chatId,
      encryptedText,
      receiverId,
      ctrl.currentUser.value.userId,
      iv,
      MessageEnum.TEXT,
    );
    saveDataToChat(receiverId, chatId, text);
  }
}
