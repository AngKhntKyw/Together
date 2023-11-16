import 'package:cloud_firestore/cloud_firestore.dart';

class Feel {
  final String feel;
  final Timestamp timestamp;
  final String? image;
  final DocumentReference userReference;

  Feel({
    required this.feel,
    required this.timestamp,
    this.image,
    required this.userReference,
  });

  // convert to a Map
  Map<String, dynamic> toMap() {
    return {
      'feel': feel,
      'timestamp': timestamp,
      'image': image,
      'owner': userReference,
    };
  }

  // Factory method to create a Feel instance from a map
  factory Feel.fromMap(Map<String, dynamic> map) {
    return Feel(
      feel: map['feel'],
      timestamp: map['timestamp'],
      image: map['image'],
      userReference: map['owner'],
    );
  }
}
