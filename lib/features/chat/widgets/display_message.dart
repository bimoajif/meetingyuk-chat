import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:realtime_chat/common/enums/message_enum.dart';

class DisplayMessage extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final bool isSender;
  const DisplayMessage({
    super.key,
    required this.message,
    required this.type,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    if (type == MessageEnum.TEXT) {
      return Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: isSender != true ? Colors.white : Colors.black,
        ),
      );
    } else if (type == MessageEnum.PRODUCT) {
      return FutureBuilder(
        future: Dio().get(
          message,
          options: Options(responseType: ResponseType.bytes),
        ),
        builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Image(
                    image: Image.memory(snapshot.data!.data).image,
                    height: MediaQuery.of(context).size.width * 0.4,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cronica Working Space',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '20 January 2023',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '08.00 - 13.00 WIB',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3880A4)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Text(
              'Error loading image',
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                color: isSender == true ? const Color(0xFF3880A4) : Colors.white,
              ),
            );
          }
        },
      );
    } else {
      return FutureBuilder(
        future: Dio().get(
          message,
          options: Options(responseType: ResponseType.bytes),
        ),
        builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
          if (snapshot.hasData) {
            return Image(
              image: Image.memory(snapshot.data!.data).image,
            );
          } else if (snapshot.hasError) {
            return const Text(
              'Error loading image',
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                color: isSender == true ? Colors.white : Colors.white,
              ),
            );
          }
        },
      );
    }
  }
}
