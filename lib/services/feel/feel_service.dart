import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_chat_app/model/feel.dart';

class FeelService extends ChangeNotifier {
  // get instance of Auth, FireStore and FireStorage
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _fireStorage = FirebaseStorage.instance;

  // CREATE FEEL
  Future<bool> createFeel(String feel, XFile? image) async {
    final User currentUser = _fireAuth.currentUser!;
    log(currentUser.toString());
    log(image.toString());
    try {
      // Get current user info
      final Reference storageReference =
          _fireStorage.ref('Images').child(image!.path);
      await storageReference.putFile(File(image.path));
      Reference reference = _fireStorage.ref('Images').child(image.path);
      String downloadUrl = await reference.getDownloadURL();
      log("result : $downloadUrl");
      log('IMAGE uploaded successfully');

      Feel newFeel = Feel(
          feel: feel,
          timestamp: Timestamp.now(),
          image: downloadUrl,
          userReference: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid));

      // Add a new message to the 'feels' collection
      await _fireStore.collection('feels').add(newFeel.toMap());
      return true;
    } catch (e) {
      log('Error creating feel: $e');
      return false;
      // Handle the error as needed
    }
  }

  // GET FEELS
  Stream<QuerySnapshot> getFeels() {
    return _fireStore
        .collection('feels')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  Future<List<Feel>> getUserFeels(String userId) async {
    try {
      // Query 'feels' collection based on user reference
      QuerySnapshot feelQuery = await _fireStore
          .collection('feels')
          .where('owner',
              isEqualTo:
                  FirebaseFirestore.instance.collection('users').doc(userId))
          .get();

      // Map the query results to a list of Feel objects
      List<Feel> userFeels = feelQuery.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return Feel.fromMap(data);
      }).toList();

      log(userFeels.toString());

      return userFeels;
    } catch (e) {
      log('Error retrieving user feels: $e');
      return [];
      // Handle the error as needed
    }
  }
}
