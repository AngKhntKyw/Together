import 'package:cloud_firestore/cloud_firestore.dart';

class Owner {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userImage;
  final bool activeNow;
  final Timestamp lastOnline;

  Owner({
    required this.userId,
    required this.userEmail,
    required this.userName,
    this.userImage,
    required this.activeNow,
    required this.lastOnline,
  });

  // convert to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'email': userEmail,
      'name': userName,
      'image': userImage,
      'lastOnline': lastOnline,
      'activeNow': activeNow,
    };
  }
}
