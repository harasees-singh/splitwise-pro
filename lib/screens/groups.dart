import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/screens/add_group.dart';
import 'package:splitwise_pro/screens/tabs/tabs.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  void logout (BuildContext context) {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        actions: [
          TextButton(onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
          }, child: const Text('Logout')),
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: const Text('Cancel')),
        ],
      );
    }); 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groups',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('groups').where('users', arrayContains: FirebaseAuth.instance.currentUser!.email).get(),
          builder: (ctx, snapshot) {
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
            final groups = snapshot.data!.docs;

            if (groups.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(50),
                child: Center(
                  child: Text(
                    'You are\'nt part of any groups yet, try creating one!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (ctx, index) => ListTile(
                title: Text(
                  groups[index]['name'],
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => TabsScreen(groupId: groups[index].id, groupName: groups[index]['name']),
                    ),
                  );
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddGroupScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        splashColor: Theme.of(context).colorScheme.onPrimary.withAlpha(40),
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
