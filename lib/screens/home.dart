import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/screens/add_transaction.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Row(
              children: [
                UserAvatar(),
                const SizedBox(width: 10),
                Text(
                  'Splitwise Pro',
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ]),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (ctx, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
              return const Center(
                child: Text('No messages yet!'),
              );
            }

            if (snapshots.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            }

            return ListView.builder(
              itemCount: snapshots.data!.docs.length,
              itemBuilder: (ctx, index) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(snapshots.data!.docs[index]['amount'].toString()),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const AddTransactionScreen(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          splashColor: Theme.of(context).colorScheme.onPrimary.withAlpha(40),
          shape: const CircleBorder(),
          child:
              Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        ),
      );
}
