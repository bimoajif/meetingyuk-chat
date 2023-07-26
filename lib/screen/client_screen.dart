import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat/features/chat/screen/chat_screen.dart';

// --------------------------------------------------------------
// Home Screen for Client
// --------------------------------------------------------------
class ClientScreen extends GetView<ChatController> {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController ctrl = Get.find();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Obx(
          () => controller.chatRoomList.length.toString() == '0'
              ? const Center(child: Loader())
              : ListView.builder(
                  itemCount: controller.chatRoomList.length,
                  itemBuilder: ((context, index) {
                    var chatContactData = controller.chatRoomList[index];

                    final recipientUser = chatContactData.users.firstWhere(
                      (user) =>
                          user.userId !=
                          ctrl.currentUser.value.userId.toHexString(),
                    );
                    final currentUser = chatContactData.users.firstWhere(
                      (user) =>
                          user.userId ==
                          ctrl.currentUser.value.userId.toHexString(),
                    );
                    DateTime timesent =
                        DateTime.parse(chatContactData.timesent);
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            controller.selectChat(
                              controller.chatRoomList[index].chatId,
                              recipientUser.userId,
                              recipientUser.name,
                              recipientUser.profilePic,
                              currentUser.roomKey,
                            );
                            Get.toNamed(ChatScreen.routeName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 0.0),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              leading: SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(recipientUser.profilePic),
                                ),
                              ),
                              title: Text(
                                recipientUser.name,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.0),
                              ),
                              subtitle: Text(
                                chatContactData.lastMessage,
                                style: const TextStyle(
                                  // color: fontColor,
                                  // fontWeight: fontWeight,
                                  fontSize: 14.0,
                                ),
                              ),
                              trailing: Text(
                                DateFormat('Hm').format(timesent),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
        ),
      ),
    );
  }
}
