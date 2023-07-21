import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';
import 'package:mongo_dart/mongo_dart.dart';

Db db = Db(
    'mongodb://bimoajif:12345@cluster0-shard-00-00.vjy66.mongodb.net:27017,cluster0-shard-00-01.vjy66.mongodb.net:27017,cluster0-shard-00-02.vjy66.mongodb.net:27017/meetingyuk-chat?ssl=true&replicaSet=atlas-13ew1s-shard-0&authSource=admin&retryWrites=true&w=majority');

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF5ABCD0)),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'please wait...',
          style: TextStyle(),
        )
            .animate(
              // this delay only happens once at the very start
              onPlay: (controller) => controller.repeat(), // loop
            )
            .fadeIn(duration: 600.ms)
            .then(delay: 200.ms) // baseline=800ms
            .fadeOut(duration: 600.ms),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}

var logger = Logger();
