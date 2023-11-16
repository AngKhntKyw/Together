import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_chat_app/pages/create_feel_page.dart';
import 'package:test_chat_app/pages/other_profile_page.dart';
import 'package:test_chat_app/pages/profile_page.dart';
import 'package:test_chat_app/pages/view_image_page.dart';
import 'package:test_chat_app/services/feel/feel_service.dart';

class FeelPage extends StatefulWidget {
  const FeelPage({super.key});

  @override
  State<FeelPage> createState() => _FeelPageState();
}

class _FeelPageState extends State<FeelPage> {
  final FeelService feelService = FeelService();

  final User user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firebaseStore = FirebaseFirestore.instance;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'Feel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ));
              },
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoURL ??
                    "https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg"),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: feelService.getFeels(),
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
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              final String imageUrl = data['image'];
              String inputString = data['timestamp'].toDate().toString();
              DateTime dateTime = DateTime.parse(inputString);

              //
              DocumentReference ownerReference = data['owner'];

              // Define a specific date format
              String formattedDate =
                  DateFormat("yyyy-MM-dd h:mm a").format(dateTime);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FutureBuilder(
                              future: ownerReference.get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => OtherProfilePage(
                                          userId: snapshot.data!['id']),
                                    ));
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                snapshot.data!['image']),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data!['name'],
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(data['feel']),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewImagePage(imgUrl: imageUrl),
                            ));
                          },
                          child: CachedNetworkImage(
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return Center(
                                  child: CircularProgressIndicator(
                                      value: progress.downloaded.toDouble()),
                                );
                              },
                              imageUrl: imageUrl),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const createFeelPage(),
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
      String ownerId) async {
    final result = await firebaseStore.collection('users').doc(ownerId).get();
    return result;
  }
}
