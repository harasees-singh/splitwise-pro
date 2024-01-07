import 'package:cloud_firestore/cloud_firestore.dart';

class UserFromFireStore {
  final String uid;
  final String email;
  final String imageUrl;
  final String username;

  UserFromFireStore.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) : 
    uid = snapshot.id,
    email = snapshot['email'],
    imageUrl = snapshot['image_url'],
    username = snapshot['username']; 

  UserFromFireStore({
    required this.uid,
    required this.email,
    required this.imageUrl,
    required this.username,
  });
}