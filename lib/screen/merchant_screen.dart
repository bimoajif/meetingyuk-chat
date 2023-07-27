import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/broadcast/screen/broadcast_screen.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat/features/chat/screen/chat_screen.dart';

// --------------------------------------------------------------
// Home Screen for Merchant
// --------------------------------------------------------------
class MerchantScreen extends GetView<ChatController> {
  const MerchantScreen({super.key});

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
                          ctrl.currentUser.value.userId,
                    );
                    final currentUser = chatContactData.users.firstWhere(
                      (user) =>
                          user.userId ==
                          ctrl.currentUser.value.userId,
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
                                  fontSize: 16.0,
                                ),
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
                        )
                      ],
                    );
                  }),
                ),
        ),
      ),
      floatingActionButton: SpeedDial(
        buttonSize: const Size(72.0, 72.0),
        childrenButtonSize: const Size(72.0, 72.0),
        overlayColor: Colors.black,
        overlayOpacity: 0.8,
        elevation: 0,
        icon: Icons.add,
        activeIcon: Icons.clear,
        backgroundColor: const Color(0xFF5ABCD0),
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.black,
        spaceBetweenChildren: 15,
        children: [
          // SpeedDialChild(
          //   child: const Icon(
          //     Icons.logout,
          //     size: 32.0,
          //   ),
          //   label: 'Log Out',
          //   labelStyle: const TextStyle(fontSize: 18.0),
          //   onTap: () {
          //     ctrl.logout();
          //   },
          // ),
          SpeedDialChild(
            child: const Icon(
              Icons.sms,
              size: 32.0,
            ),
            label: 'Send Broadcast',
            labelStyle: const TextStyle(
              fontSize: 18.0,
            ),
            onTap: () {
              Get.toNamed(BroadcastScreen.routeName);
            },
          )
        ],
      ),
    );
  }
}
