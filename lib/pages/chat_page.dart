// import 'dart:developer';
// import 'dart:io';
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:oktoast/oktoast.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:test_chat_app/components/chat_bubble.dart';
// import 'package:test_chat_app/pages/view_image_page.dart';
// import 'package:test_chat_app/services/chat/chat_service.dart';
// import 'package:better_player/better_player.dart';
// import 'package:video_player/video_player.dart';

// class ChatPage extends StatefulWidget {
//   final String receiverUserEmail;
//   final String receiverUserId;

//   const ChatPage({
//     super.key,
//     required this.receiverUserEmail,
//     required this.receiverUserId,
//   });

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController messageController = TextEditingController();
//   final FocusNode messageFocusNode = FocusNode();
//   final ChatService chatService = ChatService();
//   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   bool isShowed = true;
//   bool isShowedBottomSheet = false;
//   bool isSendingImage = false;

//   late ScrollController? scrollController = ScrollController();

//   void sendMessage() async {
//     if (messageController.text.isNotEmpty) {
//       chatService.sendMessage(
//         widget.receiverUserId,
//         messageController.text,
//         'TEXT',
//       );

//       // clear the controller after sending the message
//       messageController.clear();
//     }
//   }

//   @override
//   void initState() {
//     scrollController!.addListener(_onScroll);
//     messageFocusNode.addListener(onFocusChange);
//     loadGalleryPhotos();
//     loadGalleryVideos();

//     super.initState();
//   }

//   @override
//   void didUpdateWidget(covariant ChatPage oldWidget) {
//     scrollToBottom();
//     super.didUpdateWidget(oldWidget);
//   }

//   void onFocusChange() {
//     if (messageFocusNode.hasFocus) {
//       scrollToBottom();
//     } else {
//       null;
//     }
//   }

//   void scrollToBottom() {
//     scrollController!.animateTo(
//       scrollController!.position.maxScrollExtent + 100,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _onScroll() {
//     if (scrollController!.position.pixels ==
//         scrollController!.position.maxScrollExtent) {
//       isShowed = false;
//     } else {
//       isShowed = true;
//     }
//   }

//   @override
//   void dispose() {
//     messageController.dispose();
//     messageFocusNode.removeListener(onFocusChange);
//     messageFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//         automaticallyImplyLeading: true,
//         title: Text(
//           widget.receiverUserEmail,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 scrollToBottom();
//               },
//               icon: const Icon(Icons.arrow_downward_outlined))
//         ],
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               // messages
//               Expanded(
//                 child: buildMessageList(),
//               ),

//               //user input
//               buildMessageInput(),
//             ],
//           ),
//           Visibility(
//             visible: isShowed ? false : false,
//             child: Positioned(
//                 bottom: 80,
//                 right: 10,
//                 child: InkWell(
//                   onTap: () {
//                     scrollToBottom();
//                   },
//                   child: const CircleAvatar(
//                     radius: 25,
//                     child: Icon(Icons.arrow_downward_outlined),
//                   ),
//                 )),
//           ),
//         ],
//       ),
//     );
//   }

//   // build message list
//   Widget buildMessageList() {
//     return StreamBuilder(
//       stream: chatService.getMessages(
//           widget.receiverUserId, firebaseAuth.currentUser!.uid),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//             child: Text(snapshot.error.toString()),
//           );
//         } else if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return ListView.builder(
//           controller: scrollController,
//           addAutomaticKeepAlives: false,
//           addRepaintBoundaries: false,
//           physics: const ClampingScrollPhysics(),
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             final document = snapshot.data!.docs[index];
//             return buildMessageItem(document);
//           },
//         );
//       },
//     );
//   }

//   // build message item
//   Widget buildMessageItem(DocumentSnapshot document) {
//     Map<String, dynamic> data = document.data() as Map<String, dynamic>;

//     // align the message to the right if the sender is current user and otherwise to the left
//     var alignment = (data['senderId']) == firebaseAuth.currentUser!.uid
//         ? Alignment.centerRight
//         : Alignment.centerLeft;

//     String inputString = data['timestamp'].toDate().toString();
//     DateTime dateTime = DateTime.parse(inputString);

// // Define a specific date format
//     String formattedDate = DateFormat("yyyy-MM-dd h:mm a").format(dateTime);
//     final String messageType = data['messageType'];
//     final String imageUrl = data['message'];

//     switch (messageType) {
//       case 'IMAGE':
//         return Container(
//           alignment: alignment,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: const Color.fromARGB(255, 236, 236, 236),
//               ),
//               height: 200,
//               child: AspectRatio(
//                 aspectRatio: 3 / 4,
//                 child: InkWell(
//                   onTap: () {
//                     messageFocusNode.unfocus();
//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => ViewImagePage(imgUrl: imageUrl),
//                     ));
//                   },
//                   child: Hero(
//                     tag: imageUrl,
//                     child: CachedNetworkImage(
//                       imageBuilder: (context, imageProvider) => Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           shape: BoxShape.rectangle,
//                           image: DecorationImage(
//                             image: imageProvider,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       imageUrl: imageUrl,
//                       progressIndicatorBuilder:
//                           (context, url, downloadProgress) {
//                         double? progress = downloadProgress.progress;
//                         return Center(
//                           child: CircularProgressIndicator(
//                             strokeWidth: 4,
//                             color: const Color.fromARGB(255, 107, 205, 251),
//                             value: progress,
//                           ),
//                         );
//                       },
//                       errorWidget: (context, url, error) =>
//                           const Icon(Icons.error),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );

//       case 'TEXT':
//         return Container(
//           alignment: alignment,
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment:
//                   (data['senderId']) == firebaseAuth.currentUser!.uid
//                       ? CrossAxisAlignment.end
//                       : CrossAxisAlignment.start,
//               children: [
//                 // Text(data['senderEmail']),
//                 Tooltip(
//                   enableFeedback: true,
//                   message: formattedDate,
//                   child: ChatBubble(
//                     message: data['message'],
//                     isCurrentUserChatBubble:
//                         (data['senderId']) == firebaseAuth.currentUser!.uid,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );

//       case 'VIDEO':
//         return Container(
//           alignment: alignment,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           height: 150,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: AspectRatio(
//               aspectRatio: 16 / 9,
//               child: BetterPlayer.network(
//                 data['message'],
//                 betterPlayerConfiguration: BetterPlayerConfiguration(
//                   controlsConfiguration: BetterPlayerControlsConfiguration(
//                     enableAudioTracks: false,
//                     enableProgressText: false,
//                     enableOverflowMenu: false,
//                     enablePlayPause: false,
//                     enablePlaybackSpeed: false,
//                     enableSkips: false,
//                   ),
//                   autoDispose: false,
//                   looping: false,
//                   aspectRatio: 16 / 9,
//                   autoPlay: false,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               // child: Chewie(
//               //     controller: ChewieController(
//               //         autoPlay: true,
//               //         showControls: true,
//               //         fullScreenByDefault: false,
//               //         videoPlayerController: VideoPlayerController.networkUrl(
//               //             Uri.parse(data['message'])))),
//               // child: VideoPlayer(
//               //   VideoPlayerController.networkUrl(
//               //     videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
//               //     Uri.parse(data['message']),
//               //   ),
//               // ),
//             ),
//           ),
//         );
//       case 'LINK':
//         break;
//       default:
//         break;
//     }
//     return SizedBox();
//   }

//   //build message input
//   Widget buildMessageInput() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       child: SingleChildScrollView(
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () {
//                 // openImagesBottomSheet(context);
//                 openMediaBottomSheet(context);
//                 // _showBottomSheet(context);
//               },
//               icon: const Icon(Icons.image_rounded),
//             ),
//             Expanded(
//               child: SizedBox(
//                 height: 50,
//                 child: TextField(
//                   maxLengthEnforcement: MaxLengthEnforcement.none,
//                   selectionHeightStyle: BoxHeightStyle.tight,
//                   controller: messageController,
//                   onTap: () => scrollToBottom(),
//                   onSubmitted: (value) => scrollToBottom(),
//                   onChanged: (value) => scrollToBottom(),
//                   focusNode: messageFocusNode,
//                   obscureText: false,
//                   autofocus: false,
//                   decoration: InputDecoration(
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide(color: Colors.grey.shade200)),
//                     focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: const BorderSide(color: Colors.white)),
//                     disabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide(color: Colors.grey.shade200)),
//                     filled: true,
//                     fillColor: Colors.grey[200],
//                     hintText: "Message",
//                     hintStyle:
//                         const TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 sendMessage();
//                 scrollToBottom();
//               },
//               icon: Icon(
//                 Icons.send_rounded,
//                 color: Colors.grey[800],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   //

//   List<AssetEntity> galleryPhotos = [];
//   Future<void> loadGalleryPhotos() async {
//     final result = await PhotoManager.requestPermissionExtend();
//     if (result == PermissionState.authorized) {
//       final assets =
//           await PhotoManager.getAssetPathList(type: RequestType.image);
//       if (assets.isNotEmpty) {
//         final gallery = assets[0];
//         galleryPhotos = await gallery.getAssetListRange(
//             start: 0, end: await gallery.assetCountAsync);
//       }
//       setState(() {});
//     } else {
//       // Handle permission denied or restricted
//     }
//   }

// //

//   List<AssetEntity> galleryVideos = [];
//   Future<void> loadGalleryVideos() async {
//     final result = await PhotoManager.requestPermissionExtend();
//     if (result == PermissionState.authorized) {
//       final assets =
//           await PhotoManager.getAssetPathList(type: RequestType.video);
//       if (assets.isNotEmpty) {
//         final gallery = assets[0];
//         galleryVideos = await gallery.getAssetListRange(
//             start: 0, end: await gallery.assetCountAsync);
//       }
//       setState(() {});
//     } else {
//       // Handle permission denied or restricted
//     }
//   }

// //
//   void openMediaBottomSheet(BuildContext context) {
//     final nav = Navigator.of(context);
//     showModalBottomSheet(
//       isDismissible: true,
//       context: context,
//       showDragHandle: true,
//       isScrollControlled: true,
//       enableDrag: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       useRootNavigator: true,
//       useSafeArea: true,
//       builder: (context) {
//         return Container(
//           height: 150,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 height: 100,
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.lightBlue,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: TextButton(
//                     onPressed: () {
//                       nav.pop();
//                       openImagesBottomSheet(context);
//                     },
//                     child:
//                         Text("Image", style: TextStyle(color: Colors.white))),
//               ),
//               Container(
//                 height: 100,
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.lightBlue,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: TextButton(
//                     onPressed: () {
//                       nav.pop();
//                       openVideosBottomSheet(context);
//                     },
//                     child: Text(
//                       "Video",
//                       style: TextStyle(color: Colors.white),
//                     )),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void openImagesBottomSheet(BuildContext context) {
//     final nav = Navigator.of(context);
//     showModalBottomSheet(
//       isDismissible: true,
//       context: context,
//       showDragHandle: true,
//       isScrollControlled: true,
//       enableDrag: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       useRootNavigator: true,
//       useSafeArea: true,
//       builder: (_) {
//         return DraggableScrollableSheet(
//           shouldCloseOnMinExtent: true,
//           expand: false,
//           initialChildSize: 0.8,
//           maxChildSize: 0.9,
//           minChildSize: 0,
//           builder: (_, scrollController) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 2),
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4,
//                   crossAxisSpacing: 2,
//                   mainAxisSpacing: 2,
//                 ),
//                 itemCount: galleryPhotos.length,
//                 addAutomaticKeepAlives: false,
//                 addRepaintBoundaries: false,
//                 addSemanticIndexes: false,
//                 itemBuilder: (context, index) {
//                   final asset = galleryPhotos[index];
//                   return GestureDetector(
//                     onTap: () async {
//                       String imagePath = '';
//                       // Use the asset or its path as needed, e.g., send it in a chat
//                       await asset.file.then((value) {
//                         imagePath = value!.path;
//                       });
//                       nav.pop();
//                       // You can work with imagePath here
//                       log("Selected Image Path: $imagePath");
//                       confirmImageBottomSheet(imagePath, 'IMAGE');
//                     },
//                     child: FutureBuilder<Uint8List?>(
//                       future: asset.thumbnailData,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.done &&
//                             snapshot.hasData) {
//                           return Image.memory(snapshot.data!,
//                               fit: BoxFit.cover);
//                         }
//                         return const Center(
//                           child: SizedBox(
//                             height: 30,
//                             width: 30,
//                             child: CircularProgressIndicator(),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void openVideosBottomSheet(BuildContext context) {
//     final nav = Navigator.of(context);
//     showModalBottomSheet(
//       isDismissible: true,
//       context: context,
//       showDragHandle: true,
//       isScrollControlled: true,
//       enableDrag: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       useRootNavigator: true,
//       useSafeArea: true,
//       builder: (_) {
//         return DraggableScrollableSheet(
//           shouldCloseOnMinExtent: true,
//           expand: false,
//           initialChildSize: 0.8,
//           maxChildSize: 0.9,
//           minChildSize: 0,
//           builder: (_, scrollController) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 2),
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4,
//                   crossAxisSpacing: 2,
//                   mainAxisSpacing: 2,
//                 ),
//                 itemCount: galleryVideos.length,
//                 addAutomaticKeepAlives: false,
//                 addRepaintBoundaries: false,
//                 addSemanticIndexes: false,
//                 itemBuilder: (context, index) {
//                   final asset = galleryVideos[index];
//                   return GestureDetector(
//                     onTap: () async {
//                       String videoPath = '';
//                       // Use the asset or its path as needed, e.g., send it in a chat
//                       await asset.file.then((value) {
//                         videoPath = value!.uri.path;
//                       });
//                       nav.pop();

//                       log("Selected video Path: $videoPath");

//                       confirmImageBottomSheet(videoPath, 'VIDEO');
//                     },
//                     child: FutureBuilder<Uint8List?>(
//                       future: asset.thumbnailData,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.done &&
//                             snapshot.hasData) {
//                           return Image.memory(snapshot.data!,
//                               fit: BoxFit.cover);
//                         }
//                         return const Center(
//                           child: SizedBox(
//                             height: 30,
//                             width: 30,
//                             child: CircularProgressIndicator(),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void confirmImageBottomSheet(String filePath, String messageType) {
//     final nav = Navigator.of(context);
//     showModalBottomSheet(
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
//       showDragHandle: true,
//       context: context,
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 300,
//                 width: MediaQuery.sizeOf(context).width,
//                 child: messageType == 'IMAGE'
//                     ? Image.file(File(filePath))
//                     : AspectRatio(
//                         aspectRatio: 16 / 9,
//                         child: BetterPlayer.file(
//                           filePath,
//                           betterPlayerConfiguration: BetterPlayerConfiguration(
//                             controlsConfiguration:
//                                 BetterPlayerControlsConfiguration(
//                               enableAudioTracks: false,
//                               enableProgressText: false,
//                               enableOverflowMenu: false,
//                               enablePlayPause: false,
//                               enablePlaybackSpeed: false,
//                               enableSkips: false,
//                             ),
//                             autoDispose: false,
//                             looping: false,
//                             aspectRatio: 16 / 9,
//                             autoPlay: false,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 10),
//               InkWell(
//                 onTap: () async {
//                   showDialog(
//                       barrierDismissible: false,
//                       context: context,
//                       builder: (context) => Stack(
//                             children: [
//                               Positioned(
//                                 bottom: 200,
//                                 left: 0,
//                                 right: 0,
//                                 child: AlertDialog(
//                                     shape: CircleBorder(),
//                                     content: SizedBox(
//                                       height: 40,
//                                       width: 40,
//                                       child: Center(
//                                           child: CircularProgressIndicator()),
//                                     )),
//                               ),
//                             ],
//                           ));

//                   bool result = messageType == 'IMAGE'
//                       ? await chatService.sendImage(
//                           widget.receiverUserId, filePath, filePath)
//                       : await chatService.sendVideo(
//                           widget.receiverUserId, filePath, filePath);
//                   if (result) {
//                     nav.pop();
//                     nav.pop();
//                   } else {
//                     nav.pop();
//                     nav.pop();
//                     const OKToast(child: Text("Sending image fail"));
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.black,
//                   ),
//                   height: 50,
//                   width: MediaQuery.sizeOf(context).width,
//                   child: const Center(
//                     child: Text(
//                       "send",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
