import 'package:flutter/material.dart';
import 'package:realtime_chat/common/enums/message_enum.dart';
import 'package:realtime_chat/features/chat/widgets/display_message.dart';

class SenderMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final MessageEnum type;

  const SenderMessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Card(
              clipBehavior: Clip.hardEdge,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              color: const Color(0xFF3880A4),
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Padding(
                padding: type == MessageEnum.TEXT
                    ? const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                        bottom: 10,
                      )
                    : const EdgeInsets.only(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 0,
                      ),
                child: DisplayMessage(
                  message: message,
                  type: type,
                  isSender: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
