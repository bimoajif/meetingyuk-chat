import 'package:flutter/material.dart';

// --------------------------------------------------------------
// Widget for splash screen
// --------------------------------------------------------------
class SplashScreen extends StatelessWidget {
  final bool loading;
  const SplashScreen({super.key, required this.loading});

  @override
  Widget build(BuildContext context) {
    Widget? widget;

    if (loading == true) {
      widget = const SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    if (loading == false) {
      widget = const SizedBox(
        height: 50,
        child: Text(
          'version 1.1',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/landing-background.png'),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/images/meetingyuk-logo-white.png',
                height: 200,
                width: 200,
              ),
              SizedBox(child: widget),
            ],
          ),
        ),
      ),
    );
  }
}
