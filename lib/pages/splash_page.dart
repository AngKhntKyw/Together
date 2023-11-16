import 'package:custom_pin_keyboard/custom_pin_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:test_chat_app/services/auth/auth_gate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String pinNumber = '0';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (pinNumber == '8918') {
        //   Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => const AuthGate(),
        //   ));
        // }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "LOCK_ICON",
                      child: Icon(
                        Icons.lock,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Stay private , Connect private",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomPinKeyboard(
                  onCompleted: (pin) async {
                    pinNumber = pin;
                    if (pinNumber == '8918') {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AuthGate(),
                      ));
                    }
                  },
                  indicatorBackground: Colors.black12,
                  buttonBackground: Colors.transparent,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 32 / 24,
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                  additionalButton:
                      const Icon(Icons.ac_unit, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
