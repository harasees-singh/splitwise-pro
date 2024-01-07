import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/build_transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  List<UserFromFireStore>? _users;
  Future<QuerySnapshot<Map<String, dynamic>>>? _fetchedUsers;
  Future<QuerySnapshot<Map<String, dynamic>>> _fetchUsers() async {
    return await FirebaseFirestore.instance.collection('users').get();
  }

  void _setUsers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userSnapshots) {
    _users = userSnapshots
        .map((userSnapshot) => UserFromFireStore.fromSnapshot(userSnapshot))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchedUsers = _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Add an expense"),
      ),
      body: FutureBuilder(
        future: _fetchedUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          _setUsers(snapshot.data!.docs);
          return BuildTransaction(users: _users!);
        },
      ),
    );
  }
}
