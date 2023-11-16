import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_chat_app/model/message.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService extends ChangeNotifier {
  // get instance of Auth, FireStore and FireStorage
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _fireStorage = FirebaseStorage.instance;

  String? _chatRoomId;
  String? get chatRoomId => _chatRoomId;

  // SEND MESSAGE
  Future<void> sendMessage(
      String receiverId, String message, String messageType) async {
    //get current user info

    final String currentUserId = _fireAuth.currentUser!.uid;
    final String currentUserEmail = _fireAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      messageType: messageType,
    );

    //construct chat room id from current user id and receiver id(sorted to ensure uniqueness)
    List<String> userIds = [currentUserId, receiverId];
    userIds.sort();
    String chatRoomId = userIds.join("_");

    //add a new message to database
    _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // DELETE MESSAGE
  Future<void> deleteMessage(
      String userId, String otherUserId, String messageId) async {
    //construct chat room id from current user id and receiver id(sorted to ensure uniqueness)
    List<String> userIds = [userId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join("_");

    _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // DELETE CHAT_ROOM
  Future<void> deleteChatRoom(String userId, String otherUserId) async {
    log("DC");
    //construct chat room id from current user id and receiver id(sorted to ensure uniqueness)
    List<String> userIds = [userId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join("_");

    QuerySnapshot querySnapshot = await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await document.reference.delete();
    }
  }

  // SEND IMAGE
  Future<bool> sendImage(
      String receiverId, String imagePath, String imageName) async {
    try {
      final Reference storageReference = _fireStorage.ref().child(imageName);
      await storageReference.putFile(File(imagePath));
      Reference reference = _fireStorage.ref().child(imagePath);
      String downloadUrl = await reference.getDownloadURL();
      log("result : $downloadUrl");
      log('IMAGE uploaded successfully');
      sendMessage(receiverId, downloadUrl, 'IMAGE');
      return true;
    } catch (e) {
      log('Error uploading image: $e');
      return false;
    }
  }

  // SEND VIDEO
  Future<bool> sendVideo(
      String receiverId, String imagePath, String imageName) async {
    try {
      final Reference storageReference = _fireStorage.ref().child(imageName);
      await storageReference.putFile(File(imagePath));
      Reference reference = _fireStorage.ref().child(imagePath);
      String downloadUrl = await reference.getDownloadURL();
      log("result : $downloadUrl");
      log('VIDEO uploaded successfully');
      sendMessage(receiverId, downloadUrl, 'VIDEO');
      return true;
    } catch (e) {
      log('Error uploading image: $e');
      return false;
    }
  }

  // GET MESSAGE
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> userIds = [userId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join("_");
    log(_fireStore.collection('chat_rooms').doc(chatRoomId).id);
    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: true);
  }

  // GET ChatRoom Id
  String getChatRoomId(String userId, String otherUserId) {
    List<String> userIds = [userId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join("_");
    log(_fireStore.collection('chat_rooms').doc(chatRoomId).id);
    return _fireStore.collection('chat_rooms').doc(chatRoomId).id;
  }

  void saveChatRoomId(String chatRoomId) {
    _chatRoomId = chatRoomId;
  }
}
