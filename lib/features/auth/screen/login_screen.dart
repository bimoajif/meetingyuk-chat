import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/detail_cafe.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/screen/home_screen.dart';

class LoginScreen extends GetView<AuthController> {
  static const String routeName = '/';
  const LoginScreen({super.key});

  void tap() {
    GetStorage box = GetStorage();
    final message = box.read('user');
    Get.snackbar('hi', message.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User to Continue'),
      ),
      body: Center(
        child: Obx(
          () => controller.userList.isEmpty
              ? const Loader()
              : ListView.builder(
                  itemCount: controller.userList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        controller.login(
                          controller.userList[index].name,
                          controller.userList[index].userId,
                          controller.userList[index].profilePic,
                          controller.userList[index].isMerchant,
                          controller.userList[index].phoneNumber,
                          controller.userList[index].publicKey,
                        );
                        controller.currentUser.value.isMerchant == true ? Get.offAndToNamed(HomeScreen.routeName) : Get.offAndToNamed(DetailCard.routeName);
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
                              backgroundImage: NetworkImage(controller.userList[index].profilePic)
                            ),
                          ),
                          title: Text(
                            controller.userList[index].name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
