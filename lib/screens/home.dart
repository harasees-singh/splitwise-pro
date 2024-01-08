import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/screens/add_transaction.dart';
import 'package:splitwise_pro/widgets/transaction_tile.dart';
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
              return Center(
                child: Text(
                  'No expenses yet!',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              );
            }

            if (snapshots.hasError) {
              return Center(
                child: Text('Something went wrong!',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              );
            }

            return ListView.builder(
              itemCount: snapshots.data!.docs.length,
              itemBuilder: (ctx, index) {
                String paidByImageUrl = snapshots.data!.docs[index]['paidByImageUrl'];
                Timestamp timestamp = snapshots.data!.docs[index]['timestamp'];
                num totalAmount = snapshots.data!.docs[index]['amount'];
                dynamic splitMap = snapshots.data!.docs[index]['split'];
                num amountLent = ((splitMap.containsKey(
                            FirebaseAuth.instance.currentUser!.email)
                        ? splitMap[FirebaseAuth.instance.currentUser!.email]!
                        : 0) as num) *
                    -1;
                String paidByEmail = snapshots.data!.docs[index]['paidByEmail'];
                if (paidByEmail == FirebaseAuth.instance.currentUser!.email) {
                  amountLent = totalAmount + amountLent;
                }

                return TransactionTile(
                  paidByImageUrl: paidByImageUrl,
                  paidByEmail: snapshots.data!.docs[index]['paidByEmail'],
                  paidByUsername: snapshots.data!.docs[index]['paidByUsername'],
                  description: snapshots.data!.docs[index]['description'],
                  amount: totalAmount,
                  amountLent: amountLent,
                  timestamp: timestamp,
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
