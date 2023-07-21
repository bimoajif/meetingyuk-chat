import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat/features/chat/widgets/chat_list.dart';
import 'package:realtime_chat/features/chat/widgets/text_input_field.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat-screen';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.find();

  @override
  void initState() {
    controller.messageList.clear();
    controller.startMessageUpdates(controller.selectedMessage);
    super.initState();
  }

  @override
  void dispose() {
    controller.selectedMessage.value = '';
    controller.messageList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Row(
          children: [
            SizedBox(
              height: 40.0,
              width: 40.0,
              child: CircleAvatar(
                backgroundImage:
                    NetworkImage(controller.receiverUser.value.profilePic),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                controller.receiverUser.value.name,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.0,
                ),
              ),
            )
          ],
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chat-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: ChatList(),
            ),
            TextInputField(
              chatId: controller.selectedRoom.value.chatId,
              receiverId: controller.receiverUser.value.userId,
              roomKey: controller.selectedRoom.value.roomKey,
            )
          ],
        ),
      ),
    );
  }
}
