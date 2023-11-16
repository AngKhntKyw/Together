import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_chat_app/components/my_button.dart';
import 'package:test_chat_app/components/my_text_field.dart';
import 'package:test_chat_app/services/auth/auth_service.dart';

class LogInPage extends StatefulWidget {
  final void Function()? onTap;
  const LogInPage({
    super.key,
    this.onTap,
  });

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  ///text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //text focusNodes
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  ///login function
  void logIn() async {
    ///unfocus textFields
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();

    //get the auth service
    final authService = context.read<AuthService>();

    ///try user sign in
    try {
      await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      ///logo
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    enableFeedback: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Hero(
                      tag: "LOCK_ICON",
                      child: Icon(
                        Icons.lock,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  ///welcome back message
                  const Text("Welcome back, you've been missed"),
                  const SizedBox(height: 25),

                  ///email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    focusNode: emailFocusNode,
                  ),
                  const SizedBox(height: 10),

                  ///password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    focusNode: passwordFocusNode,
                  ),
                  const SizedBox(height: 25),

                  ///sign in button
                  MyButton(onTap: logIn, text: "Login"),
                  const SizedBox(height: 50),

                  //new member? sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not a member?"),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Register now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
