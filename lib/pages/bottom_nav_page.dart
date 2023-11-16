import 'package:flutter/material.dart';
import 'package:test_chat_app/pages/feel_page.dart';
import 'package:test_chat_app/pages/home_page.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    FeelPage(),
    HomePage(),
    // WebSocketChatPage(),
    // VideoCallPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.other_houses),
            icon: Icon(Icons.other_houses_outlined),
            label: 'Feel',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.chat_rounded),
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          // BottomNavigationBarItem(
          //     activeIcon: Icon(Icons.send_time_extension),
          //     icon: Icon(Icons.send_time_extension_outlined),
          //     label: 'WebSocket'),
        ],
      ),
    );
  }
}
