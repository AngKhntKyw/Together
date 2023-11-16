import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_chat_app/pages/chatting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //get the auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///user sign out
  // void signOut() async {
  //   final authService = context.read<AuthService>();
  //   authService.signOut();
  // }

  @override
  void initState() {
    super.initState();

    log("Enter Home Page");
    _firestore.collection('users').doc(user!.uid).update({'activeNow': true});
  }

  @override
  void dispose() async {
    super.dispose();
    log("Quit Home Page");
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .update({'activeNow': false, 'lastOnline': Timestamp.now()});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'activeNow': true}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 236, 236, 236),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            title: const Text(
              "Chat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            // actions: [
            //   IconButton(
            //     onPressed: signOut,
            //     icon: const Icon(Icons.logout_outlined),
            //   ),
            // ],
          ),
          body: buildUserList(),
        );
      },
    );
  }

  // build a list of users exceot for the current logged in user
  Widget buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) =>
              buildUserListItem(snapshot.data!.docs[index]),
        );
      },
    );
  }

  // build individual user list item
  Widget buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    //display all users except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(data['image']),
        ),
        title: Text(
          data['name'] ?? data['email'],
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          data['email'],
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          // pass the clicked user's uid to the chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChattingPage(
                receiverUserEmail: data['name'] ?? data['email'],
                receiverUserId: data['id'],
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
