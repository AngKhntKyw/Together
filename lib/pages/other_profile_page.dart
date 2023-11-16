import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_chat_app/pages/view_image_page.dart';
import 'package:test_chat_app/services/feel/feel_service.dart';

class OtherProfilePage extends StatefulWidget {
  final String userId;
  const OtherProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  final FeelService feelService = FeelService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    log("user ID : ${widget.userId}");

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      body: FutureBuilder(
        future: firestore.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot1) {
          return FutureBuilder(
            future: feelService.getUserFeels(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: true,
                    elevation: 1,
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ViewImagePage(
                                          imgUrl: snapshot1.data!['image']),
                                    ));
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: CachedNetworkImageProvider(
                                        snapshot1.data!['image']),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot1.data!['name'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(snapshot1.data!['email']),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(color: Colors.grey, thickness: 0.6),
                            const SizedBox(height: 20),
                            Text(
                              'Feel',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final feel = snapshot.data![index];
                      String inputString = feel.timestamp.toDate().toString();
                      DateTime dateTime = DateTime.parse(inputString);
                      String formattedDate =
                          DateFormat("yyyy-MM-dd h:mm a").format(dateTime);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              snapshot1.data!['image']),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot1.data!['name'],
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(feel.feel),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          ViewImagePage(imgUrl: feel.image!),
                                    ));
                                  },
                                  child: CachedNetworkImage(
                                      progressIndicatorBuilder:
                                          (context, url, progress) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                              value: progress.downloaded
                                                  .toDouble()),
                                        );
                                      },
                                      imageUrl: feel.image!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
