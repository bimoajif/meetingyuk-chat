import 'package:realtime_chat/common/enums/message_enum.dart';

class MessageModel {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final String timesent;
  final String iv;
  final MessageEnum type;

  MessageModel({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timesent,
    required this.iv,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timesent': timesent,
      'iv': iv,
      'type': type.type,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> message) {
    return MessageModel(
      chatId: message['chatId'],
      senderId: message['senderId'],
      receiverId: message['receiverId'],
      message: message['text'],
      timesent: message['timesent'],
      iv: message['iv'],
      type: (message['type'] as String).toEnum(),
      // type: message['type']
    );
  }
}
