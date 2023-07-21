import 'package:flutter/material.dart';
import 'package:realtime_chat/common/enums/message_enum.dart';
import 'package:realtime_chat/features/chat/widgets/display_message.dart';

class RecipientMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final MessageEnum type;
  const RecipientMessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              clipBehavior: Clip.hardEdge,
              elevation: 1,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              color: Colors.white,
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
                  isSender: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
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
