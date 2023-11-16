import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_chat_app/components/my_button.dart';
import 'package:test_chat_app/components/my_text_field.dart';
import 'package:test_chat_app/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({
    super.key,
    this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  ///text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  ///text focusNodes
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  ///sign up function
  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    // get the auth service
    final authService = context.read<AuthService>();

    try {
      await authService.signUpWithEmailAndPassword(
        nameController.text,
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
                  const Text("Let's create an account for you"),
                  const SizedBox(height: 25),

                  ///name textField
                  MyTextField(
                    controller: nameController,
                    hintText: "Name",
                    obscureText: false,
                    focusNode: nameFocusNode,
                  ),
                  const SizedBox(height: 10),

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
                  const SizedBox(height: 10),

                  ///confirm password textfield
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm password",
                    obscureText: true,
                    focusNode: confirmPasswordFocusNode,
                  ),
                  const SizedBox(height: 25),

                  ///sign up button
                  MyButton(onTap: signUp, text: "Sign up"),
                  const SizedBox(height: 50),

                  //new member? sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already a member?"),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
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
