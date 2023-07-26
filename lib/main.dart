import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => AuthController());
  final AuthController ctrl = Get.find();

  // --------------------------------------------------------------
  // Call getCollection function from AuthController
  // --------------------------------------------------------------
  ctrl.getCollection();

  // --------------------------------------------------------------
  // Initialize GetStorage to save and retrieve local data
  // --------------------------------------------------------------
  await GetStorage.init();

  // --------------------------------------------------------------
  // Function to run App
  // --------------------------------------------------------------
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MaterialColor meetingyukColor = const MaterialColor(
    0xFF3880A4,
    <int, Color>{
      50: Color(0xFFE4F6F9),
      100: Color(0xFFBAE8F1),
      200: Color(0xFF91D9E8),
      300: Color(0xFF70C9E0),
      400: Color(0xFF5CBDDC),
      500: Color(0xFF4EB2D8),
      600: Color(0xFF46A4CA),
      700: Color(0xFF3C91B8),
      800: Color(0xFF3880A4),
      900: Color(0xFF2C6082),
    },
  );

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: meetingyukColor,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      getPages: Routes.pages(),
      defaultTransition: Transition.native,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
    );
  }
}
