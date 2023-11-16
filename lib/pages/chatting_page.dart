import 'dart:developer';
import 'dart:ui';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:test_chat_app/components/chat_bubble.dart';
import 'package:test_chat_app/pages/media_bottom_sheet_page.dart';
import 'package:test_chat_app/pages/other_profile_page.dart';
import 'package:test_chat_app/pages/view_image_page.dart';
import 'package:test_chat_app/services/chat/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChattingPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  const ChattingPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserId,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final ChatService chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isShowed = true;
  bool isShowedBottomSheet = false;
  bool isSendingImage = false;
  List<String?> allMediaPaths = [];
  bool isChatBubbleSelected = false;

  late ScrollController? scrollController = ScrollController();

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      chatService.sendMessage(
        widget.receiverUserId,
        messageController.text,
        'TEXT',
      );

      // clear the controller after sending the message
      messageController.clear();
    }
  }

  @override
  void initState() {
    scrollController!.addListener(_onScroll);
    messageFocusNode.addListener(onFocusChange);
    super.initState();
  }

  void onFocusChange() {
    if (messageFocusNode.hasFocus) {
      scrollToBottom();
    } else {
      null;
    }
  }

  void scrollToBottom() {
    scrollController!.animateTo(
      scrollController!.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onScroll() {
    if (scrollController!.position.pixels ==
        scrollController!.position.maxScrollExtent) {
      isShowed = false;
    } else {
      isShowed = true;
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    messageFocusNode.removeListener(onFocusChange);
    messageFocusNode.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
      String userId) async {
    final result = await firestore.collection('users').doc(userId).get();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    log("Build again");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: true,
        title: FutureBuilder(
          future: getUserInfo(widget.receiverUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      OtherProfilePage(userId: widget.receiverUserId),
                ));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(snapshot.data!['image']),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.circle,
                          size: 15,
                          color: snapshot.data!['activeNow']
                              ? Colors.green
                              : const Color.fromARGB(255, 64, 63, 63),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        snapshot.data!['name'],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      snapshot.data!['activeNow']
                          ? Text(
                              'active now',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green),
                            )
                          : Text(
                              timeago.format(
                                  snapshot.data!['lastOnline'].toDate()),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.black38,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     await chatService.deleteChatRoom(
          //         firebaseAuth.currentUser!.uid, widget.receiverUserId);
          //   },
          //   icon: const Icon(Icons.delete),
          // ),
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'CLEAR_CHAT') {
                await chatService.deleteChatRoom(
                    firebaseAuth.currentUser!.uid, widget.receiverUserId);
              }
            },
            tooltip: 'Menu',
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    value: 'CLEAR_CHAT',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text("Clear chat"),
                      ],
                    ))
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: buildMessageList(),
          ),

          //user input
          buildMessageInput(),
        ],
      ),
    );
  }

  // build message list
  Widget buildMessageList() {
    return StreamBuilder(
      stream: chatService.getMessages(
          widget.receiverUserId, firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          controller: scrollController,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          physics: const ClampingScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final document = snapshot.data!.docs[index];

            return buildMessageItem(document, snapshot.data!.docs[index].id);
          },
        );
      },
    );
  }

  // build message item
  Widget buildMessageItem(DocumentSnapshot document, String messageId) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the message to the right if the sender is current user and otherwise to the left
    var alignment = (data['senderId']) == firebaseAuth.currentUser!.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;

    String inputString = data['timestamp'].toDate().toString();
    DateTime dateTime = DateTime.parse(inputString);

// Define a specific date format
    String formattedDate = DateFormat("yyyy-MM-dd h:mm a").format(dateTime);
    final String messageType = data['messageType'];
    final String imageUrl = data['message'];
    // final String messageId = document['index'].id;

    switch (messageType) {
      case 'IMAGE':
        return GestureDetector(
          onLongPressStart: (details) {
            showPopupMenu(
                context, details.globalPosition, data['message'], messageId);
          },
          child: Container(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 236, 236, 236),
                ),
                height: 200,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: InkWell(
                    onTap: () {
                      messageFocusNode.unfocus();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ViewImagePage(imgUrl: imageUrl),
                      ));
                    },
                    child: Hero(
                      tag: imageUrl,
                      child: CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        imageUrl: imageUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          double? progress = downloadProgress.progress;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: const Color.fromARGB(255, 107, 205, 251),
                              value: progress,
                            ),
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

      case 'TEXT':
        return Container(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment:
                  (data['senderId']) == firebaseAuth.currentUser!.uid
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                // Text(data['senderEmail']),

                GestureDetector(
                  onLongPressStart: (details) {
                    showPopupMenu(context, details.globalPosition,
                        data['message'], messageId);
                  },
                  child: ChatBubble(
                    message: data['message'],
                    isCurrentUserChatBubble:
                        (data['senderId']) == firebaseAuth.currentUser!.uid,
                    chatTime: formattedDate,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'VIDEO':
        return Container(
          alignment: alignment,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer.network(
                imageUrl,
                betterPlayerConfiguration: BetterPlayerConfiguration(
                  controlsConfiguration: BetterPlayerControlsConfiguration(
                    enableAudioTracks: false,
                    enableProgressText: false,
                    enableOverflowMenu: false,
                    enablePlayPause: false,
                    enablePlaybackSpeed: false,
                    enableSkips: false,
                  ),
                  autoDispose: false,
                  looping: false,
                  aspectRatio: 16 / 9,
                  fullScreenByDefault: false,
                  autoPlay: false,
                  fit: BoxFit.contain,
                ),
              ),
              //         // child: Chewie(
              //         //     controller: ChewieController(
              //         //         autoPlay: true,
              //         //         showControls: true,
              //         //         fullScreenByDefault: false,
              //         //         videoPlayerController: VideoPlayerController.networkUrl(
              //         //             Uri.parse(data['message'])))),
              //         // child: VideoPlayer(
              //         //   VideoPlayerController.networkUrl(
              //         //     videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
              //         //     Uri.parse(data['message']),
              //         //   ),
              //         // ),
            ),
          ),
        );
      case 'LINK':
        break;
      default:
        break;
    }
    return SizedBox();
  }

  //build message input
  Widget buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SingleChildScrollView(
        child: Row(
          children: [
            IconButton(
              onPressed: () => openMediaSelectBottomSheet(context),
              icon: const Icon(Icons.image_rounded),
            ),
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextField(
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  selectionHeightStyle: BoxHeightStyle.tight,
                  controller: messageController,
                  onTap: () => scrollToBottom(),
                  onSubmitted: (value) => scrollToBottom(),
                  onChanged: (value) => scrollToBottom(),
                  focusNode: messageFocusNode,
                  obscureText: false,
                  autofocus: false,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Message",
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                sendMessage();
                scrollToBottom();
              },
              icon: Icon(
                Icons.send_rounded,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openMediaSelectBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      showDragHandle: true,
      builder: (context) {
        return MediaBottomSheetPage(
          receiverUserId: widget.receiverUserId,
          receiverUserEmail: widget.receiverUserEmail,
        );
      },
    );
  }

  void showPopupMenu(BuildContext context, Offset tapPosition, String message,
      String messageId) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          tapPosition - Offset(60, 100) & Size(40, 40),
          Offset.zero & overlay.size),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 20),
              const SizedBox(width: 10),
              Text('Copy'),
            ],
          ),
        ),
        PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20),
                const SizedBox(width: 10),
                Text('Delete'),
              ],
            )),
        // Add more menu items as needed
      ],
    ).then((value) async {
      if (value == 'copy') {
        // Handle the 'Copy' action
        print('Copying message: $message');
      } else if (value == 'delete') {
        await chatService.deleteMessage(
            firebaseAuth.currentUser!.uid, widget.receiverUserId, messageId);
      }
    });
  }
}
