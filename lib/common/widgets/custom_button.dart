import 'package:flutter/material.dart';

// --------------------------------------------------------------
// Widget for customize button
// --------------------------------------------------------------
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onpressed;

  const CustomButton({super.key, required this.text, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5ABCD0),
          minimumSize: const Size(double.infinity, 50)),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 5,
          color: Colors.white,
        ),
      ),
    );
  }
}
