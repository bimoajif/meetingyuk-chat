import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/common/widgets/custom_button.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';

class BroadcastScreen extends StatefulWidget {
  static const String routeName = '/broadcast-screen';
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  List selectedReceiver = [];
  List selectedChat = [];
  List selectedKey = [];
  final TextEditingController _messageController = TextEditingController();

  final AuthController ctrl = Get.find();
  final ChatController controller = Get.find();

  void onReceiverSelected(bool selected, chatId, receiverId, roomKey) {
    if (selected == true) {
      setState(() {
        selectedReceiver.add(receiverId);
        selectedChat.add(chatId);
        selectedKey.add(roomKey);
      });
    } else {
      setState(() {
        selectedReceiver.remove(receiverId);
        selectedChat.remove(chatId);
        selectedKey.remove(roomKey);
      });
    }
  }

  bool isCheckedA = false;
  bool isCheckedB = false;
  bool isCheckedC = false;
  bool isCheckedD = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78.0,
        centerTitle: false,
        title: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Image.asset(
              'assets/images/meetingyuk-logo.png',
              height: 28,
              semanticLabel: 'MeetingYuk Logo',
            ),
          ],
        ),
        foregroundColor: Colors.black,
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesan Broadcast',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              TextField(
                controller: _messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autocorrect: false,
                decoration: const InputDecoration(
                    hintText: 'Masukkan pesan broadcast...'),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              const Text('Pilih tujuan pesan:'),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.chatRoomList.length,
                itemBuilder: (context, index) {
                  final recipientUser =
                      controller.chatRoomList[index].users.firstWhere(
                    (user) =>
                        user.userId !=
                        ctrl.currentUser.value.userId.toHexString(),
                  );
                  final currentUser =
                      controller.chatRoomList[index].users.firstWhere(
                    (user) =>
                        user.userId ==
                        ctrl.currentUser.value.userId.toHexString(),
                  );
                  return ListTile(
                    title: Text(recipientUser.name),
                    trailing: Checkbox(
                      value: selectedChat
                          .contains(controller.chatRoomList[index].chatId),
                      onChanged: (val) {
                        onReceiverSelected(
                            val!, controller.chatRoomList[index].chatId, recipientUser.userId, currentUser.roomKey);
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: CustomButton(
                    text: 'KIRIM',
                    onpressed: () {
                      if (_messageController.text == '' || selectedChat.isEmpty) {
                        Get.defaultDialog(
                          title: 'Gagal',
                          content: const Text('Silakan isi teks pesan dan pilih tujuan pesan'),
                        );
                      } else {
                        controller.sendBroadcastMessage(text: _messageController.text, chatId: selectedChat, receiverId: selectedReceiver, roomKey: selectedKey);
                        Get.back();
                        Get.defaultDialog(
                          title: 'Success',
                          content: Text('Pesan Broadcast Berhasil Dikirim!'),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
