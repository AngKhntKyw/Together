import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_chat_app/services/feel/feel_service.dart';

class createFeelPage extends StatefulWidget {
  const createFeelPage({super.key});

  @override
  State<createFeelPage> createState() => _createFeelPageState();
}

class _createFeelPageState extends State<createFeelPage> {
  bool isImagePicked = false;
  XFile? imageFile;
  final TextEditingController feelTextController = TextEditingController();
  final FocusNode feelFocusNode = FocusNode();
  final FeelService feelService = FeelService();

  @override
  void dispose() {
    feelTextController.dispose();
    feelFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: true,
        title: Text(
          'Create feel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    TextField(
                      controller: feelTextController,
                      focusNode: feelFocusNode,
                      obscureText: false,
                      maxLines: 8,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'feel',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        imageFile = await pickPhoto();
                        if (imageFile != null) {
                          setState(() {
                            isImagePicked = true;
                          });
                        }
                      },
                      child: !isImagePicked
                          ? SizedBox()
                          : Image.file(File(imageFile!.path)),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () async {
                      imageFile = await pickPhoto();
                      if (imageFile != null) {
                        setState(() {
                          isImagePicked = true;
                        });
                      }
                    },
                    icon: Icon(Icons.image)),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            backgroundColor: const Color.fromARGB(53, 255, 255, 255),
            enableDrag: false,
            isScrollControlled: true,
            useRootNavigator: true,
            context: context,
            builder: (context) {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()),
                ),
              );
            },
          );
          await feelService.createFeel(feelTextController.text, imageFile);
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Icon(Icons.check_sharp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<XFile?> pickPhoto() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    return result;
  }
}
