import 'dart:developer';
import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:test_chat_app/pages/video_call_page.dart';
import 'package:test_chat_app/services/chat/chat_service.dart';

class MediaBottomSheetPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  const MediaBottomSheetPage({
    super.key,
    required this.receiverUserId,
    required this.receiverUserEmail,
  });

  @override
  State<MediaBottomSheetPage> createState() => _MediaBottomSheetPageState();
}

class _MediaBottomSheetPageState extends State<MediaBottomSheetPage> {
  ChatService chatService = ChatService();
  User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    log("Build again");
    return SizedBox(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  final photo = await takePhoto();
                  Navigator.pop(context);
                  reviewMediaBottomSheet(context, photo!.path, 'IMAGE');
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.white,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final file = await pickFile();
                  log("File : ${file!.paths.first}");

                  Navigator.pop(context);

                  String mediaType = 'UndefinedMediaType';
                  final fileExtension =
                      path.extension(file.paths.first!).toLowerCase();
                  if (fileExtension == '.jpg' || fileExtension == '.png') {
                    mediaType = 'IMAGE';
                  } else if (fileExtension == '.mp4') {
                    mediaType = 'VIDEO';
                  }

                  reviewMediaBottomSheet(context, file.paths.first!, mediaType);
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                      Text(
                        "Image",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_present_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                    Text(
                      "File",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoCallPage(),
                  ));
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_chat,
                        size: 50,
                        color: Colors.white,
                      ),
                      Text(
                        "Video Call",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<XFile?> takePhoto() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
    return result;
  }

  Future<FilePickerResult?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );
    return result;
  }

  void reviewMediaBottomSheet(
      BuildContext context, String mediaPath, String mediaType) {
    log("TYPE : $mediaType");
    log("PATH : $mediaPath");

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 350,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 280,
                  child: mediaType == 'IMAGE'
                      ? Image.file(
                          File(mediaPath),
                          fit: BoxFit.contain,
                        )
                      : BetterPlayer.file(
                          mediaPath,
                          betterPlayerConfiguration: BetterPlayerConfiguration(
                              autoPlay: true,
                              autoDispose: false,
                              fit: BoxFit.contain,
                              controlsConfiguration:
                                  BetterPlayerControlsConfiguration(
                                enableAudioTracks: false,
                                enableMute: false,
                                enableSkips: false,
                                enableSubtitles: false,
                                enableProgressBar: false,
                                enablePlaybackSpeed: false,
                                enablePlayPause: false,
                                enableQualities: false,
                                enableFullscreen: false,
                              )),
                        ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    showModalBottomSheet(
                      enableDrag: false,
                      backgroundColor: Color.fromARGB(83, 255, 255, 255),
                      context: context,
                      isDismissible: false,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10))),
                      showDragHandle: true,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 350,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    if (mediaType == 'IMAGE') {
                      await chatService.sendImage(
                          widget.receiverUserId, mediaPath, mediaPath);
                    } else if (mediaType == 'VIDEO') {
                      await chatService.sendVideo(
                          widget.receiverUserId, mediaPath, mediaPath);
                    }
                    Navigator.pop(context);

                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    height: 50,
                    width: MediaQuery.sizeOf(context).width,
                    child: const Center(
                      child: Text(
                        "send",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
