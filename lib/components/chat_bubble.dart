import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUserChatBubble;
  final String chatTime;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUserChatBubble,
    required this.chatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isCurrentUserChatBubble
            ? const Color.fromARGB(255, 107, 205, 251)
            : const Color.fromARGB(255, 245, 150, 213),
      ),
      child: Column(
        crossAxisAlignment: isCurrentUserChatBubble
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          Text(
            chatTime,
            style: TextStyle(
                fontSize: 10, color: const Color.fromARGB(224, 255, 255, 255)),
          ),
        ],
      ),
    );
  }
}
