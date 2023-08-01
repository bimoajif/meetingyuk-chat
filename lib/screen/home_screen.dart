import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/screen/client_screen.dart';
import 'package:realtime_chat/screen/merchant_screen.dart';

class HomeScreen extends GetView<AuthController> {
  static const String routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.currentUser.value.isMerchant == 1
        ? const MerchantScreen()
        : const ClientScreen();
  }
}
