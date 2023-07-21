import 'package:get/get.dart';
import 'package:realtime_chat/detail_cafe.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/auth/screen/login_screen.dart';
import 'package:realtime_chat/features/broadcast/screen/broadcast_screen.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat/features/chat/screen/chat_screen.dart';
import 'package:realtime_chat/screen/home_screen.dart';

class Routes {
  static List<GetPage> pages() => [
        GetPage(
          name: LoginScreen.routeName,
          page: () => const LoginScreen(),
          binding: BindingsBuilder(() {
            Get.put(AuthController());
          }),
        ),
        GetPage(
          name: HomeScreen.routeName,
          page: () => const HomeScreen(),
          binding: BindingsBuilder(() {
            Get.put(ChatController());
          }),
        ),
        GetPage(
          name: ChatScreen.routeName,
          page: () => const ChatScreen(),
        ),
        GetPage(
          name: DetailCard.routeName,
          page: () => const DetailCard(),
        ),
        GetPage(
          name: BroadcastScreen.routeName,
          page: () => const BroadcastScreen(),
        ),
      ];
}
