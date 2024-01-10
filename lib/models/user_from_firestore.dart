import 'package:cloud_firestore/cloud_firestore.dart';

class UserFromFireStore {
  final String uid;
  final String email;
  final String imageUrl;
  final String username;
  final bool isVerified;

  UserFromFireStore.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) : 
    uid = snapshot.id,
    email = snapshot['email'],
    imageUrl = snapshot['image_url'],
    username = snapshot['username'],
    isVerified = snapshot['verified']; 

  UserFromFireStore({
    required this.uid,
    required this.email,
    required this.imageUrl,
    required this.username,
    required this.isVerified,
  });
}