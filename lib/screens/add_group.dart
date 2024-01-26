import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/screens/search_users.dart';
import 'package:splitwise_pro/screens/verify_email.dart';
import 'package:splitwise_pro/widgets/button.dart';
import 'package:splitwise_pro/widgets/user_tile.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  String groupName = '';
  List<UserFromFireStore> addedUsers = [];
  bool _isLoading = false;

  void onAddNewUser(UserFromFireStore user) {
    if (addedUsers.where((element) => element.email == user.email).isNotEmpty) {
      return;
    }
    setState(() {
      addedUsers.add(user);
    });
  }

  void onDelete(UserFromFireStore user) {
    setState(() {
      addedUsers.removeWhere((element) => user.email == element.email);
    });
  }

  void createNewGroup() async {
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('group name cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (addedUsers.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('please select atleast one user'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (addedUsers
        .where((element) =>
            element.email == FirebaseAuth.instance.currentUser!.email)
        .isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'you cannot create a group without adding yourself in it'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName,
        'users': addedUsers.map((user) => user.email).toList()
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
      return const VerifyEmailScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Group Name',
              ),
              onChanged: (value) => groupName = value,
            ),
            const SizedBox(
              height: 20,
            ),
            SearchUsersScreen(onAddNewUser: onAddNewUser),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: addedUsers
                      .map((user) => UserTile(
                            user: user,
                            onDelete: onDelete,
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Button(
                isLoading: _isLoading,
                onSubmit: () {
                  createNewGroup();
                },
                buttonTitle: 'Create New Group')
          ],
        ),
      ),
    );
  }
}
