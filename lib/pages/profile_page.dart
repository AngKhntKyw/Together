import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_chat_app/pages/view_image_page.dart';
import 'package:test_chat_app/services/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameEditingController = TextEditingController();

  ///user sign out
  void signOut() async {
    final authService = context.read<AuthService>();
    authService.signOut();
    Navigator.pop(context);
  }

  final FocusNode nameFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    AuthService authService = AuthService();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: true,
        title: Text(
          'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {},
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ViewImagePage(
                            imgUrl: user.photoURL ??
                                "https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg",
                          ),
                        ));
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(
                          user!.photoURL ??
                              "https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg",
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () async {
                          final photo = await takePhoto();
                          showModalBottomSheet(
                            backgroundColor:
                                const Color.fromARGB(53, 255, 255, 255),
                            enableDrag: false,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            },
                          );
                          bool result =
                              await authService.updateProfileImage(photo!.path);
                          if (result) {
                            Navigator.of(context).pop();
                            setState(() {});
                          }
                        },
                        child: Icon(
                          Icons.change_circle,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              ListTile(
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        insetPadding: EdgeInsets.all(30),
                        content: SizedBox(
                          width: 400,
                          height: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: nameEditingController,
                                      focusNode: nameFocusNode,
                                      obscureText: false,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.white),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        hintText: "change name",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )),
                                      const SizedBox(width: 20),
                                      TextButton(
                                          onPressed: () async {
                                            await authService.updateUserName(
                                                user.uid,
                                                nameEditingController.text);

                                            Navigator.of(context).pop();
                                            setState(() {
                                              nameEditingController.clear();
                                            });
                                          },
                                          child: Text('Confirm'))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: Colors.grey[200],
                title: Text(
                  user.displayName!,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: Colors.grey[200],
                title: Text(
                  user.email!,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<XFile?> takePhoto() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    return result;
  }
}
