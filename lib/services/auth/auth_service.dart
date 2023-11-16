import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:test_chat_app/model/owner.dart';

class AuthService extends ChangeNotifier {
  // instance of Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance of fireStore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _fireStorage = FirebaseStorage.instance;

  // user sign in
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // add a new document for the user in users collection if it doesn't already exists
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'activeNow': true,
        'lastOnline': Timestamp.now(),
      }, SetOptions(merge: true));

      return userCredential;
    }
    //catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // user register
  Future<UserCredential> signUpWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      // sign up
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firebaseAuth.currentUser!.updateDisplayName(name);
      await _firebaseAuth.currentUser!.updatePhotoURL(
          "https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg");
      await _firebaseAuth.currentUser!.reload();
      User? updatedUser = _firebaseAuth.currentUser;

      log("User Credential :$updatedUser");

      Owner newOwner = new Owner(
        userId: updatedUser!.uid,
        userEmail: updatedUser.email!,
        userName: updatedUser.displayName!,
        userImage: updatedUser.photoURL,
        activeNow: true,
        lastOnline: Timestamp.now(),
      );

      // after creating user, create a new document for user in user collection
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newOwner.toMap());

      notifyListeners();
      return userCredential;
    }
    //catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> updateUserName(String userId, String name) async {
    await _firebaseAuth.currentUser!.updateDisplayName(name);
    await _firestore.collection('users').doc(userId).update({'name': name});
  }

  // UPDATE PROFILE IMAGE

  Future<bool> updateProfileImage(String imagePath) async {
    try {
      final Reference storageReference = _fireStorage.ref().child(imagePath);
      await storageReference.putFile(File(imagePath));
      Reference reference = _fireStorage.ref().child(imagePath);
      String downloadUrl = await reference.getDownloadURL();
      log("result : $downloadUrl");
      log('IMAGE uploaded successfully');
      await _firebaseAuth.currentUser!.updatePhotoURL(downloadUrl);
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({'image': downloadUrl});
      notifyListeners();
      return true;
    } catch (e) {
      log('Error uploading image: $e');
      return false;
    }
  }

  // user sign out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
