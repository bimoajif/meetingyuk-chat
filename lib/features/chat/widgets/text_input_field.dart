import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/colors.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';

class TextInputField extends StatefulWidget {
  final String receiverId;
  final String chatId;
  final String roomKey;
  const TextInputField({
    super.key,
    required this.receiverId,
    required this.chatId,
    required this.roomKey,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();

  final ChatController ctrl = Get.find();

  Color sendButtonColor = Colors.grey;

  void sendTextMessage() async {
    if (isShowSendButton) {
      if (_messageController.text.trim() != '') {
        ctrl.sendTextMessage(
          chatId: widget.chatId,
          text: _messageController.text.trim(),
          receiverId: widget.receiverId,
          roomKey: widget.roomKey,
        );
        setState(() {
          _messageController.text = '';
        });
      } else {
        Get.defaultDialog(title: 'ERROR', content: const Text('message cannot be empty!'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (val) {
        if (val.isNotEmpty) {
          setState(() {
            sendButtonColor = primaryColor;
            isShowSendButton = true;
          });
        } else {
          setState(() {
            sendButtonColor = Colors.grey;
            isShowSendButton = false;
          });
        }
      },
      controller: _messageController,
      keyboardType: TextInputType.multiline,
      autocorrect: false,
      decoration: InputDecoration(
        border: InputBorder.none,
        // constraints: const BoxConstraints.expand(height: 90),
        contentPadding: const EdgeInsets.only(
          top: 25,
          left: 24,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            top: 0.0,
            left: 10.0,
          ),
          child: SpeedDial(
            switchLabelPosition: true,
            icon: Icons.attach_file,
            activeIcon: Icons.clear,
            animationCurve: Curves.easeOut,
            overlayColor: Colors.black,
            overlayOpacity: 0.3,
            spacing: 12,
            backgroundColor: Colors.transparent,
            elevation: 0,
            childMargin: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 0.0,
            ),
            children: [
              SpeedDialChild(
                onTap: () {},
                child: const Icon(
                  Icons.camera_alt,
                ),
                label: 'take photo',
              ),
              SpeedDialChild(
                onTap: () {},
                child: const Icon(
                  Icons.image,
                ),
                label: 'attach image',
              )
            ],
            // color: primaryColor,
          ),
        ),
        hintText: 'Tulis Pesan Anda...',
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        suffixIcon: GestureDetector(
          onTap: sendTextMessage,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(0),
              ),
              color: sendButtonColor,
            ),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
