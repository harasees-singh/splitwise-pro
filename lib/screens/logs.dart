import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/util/enums/transaction_action.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/widgets/transaction_tile.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('logs')
            .orderBy('logTimestamp', descending: true)
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
                'No logs yet!',
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            );
          }


          return ListView.builder(
            itemCount: snapshots.data!.docs.length,
            itemBuilder: (ctx, index) {
              TransactionAction action = TransactionAction.values
                  .byName(snapshots.data!.docs[index]['action']);
              TransactionType type = TransactionType.values
                  .byName(snapshots.data!.docs[index]['type']);
              String id = snapshots.data!.docs[index].id;
              String paidByImageUrl =
                  snapshots.data!.docs[index]['paidByImageUrl'];
              Timestamp timestamp = snapshots.data!.docs[index]['timestamp'];
              num totalAmount = snapshots.data!.docs[index]['amount'];
              Map<String, dynamic> splitMap =
                  snapshots.data!.docs[index]['split'];
              num amountLent = ((splitMap
                          .containsKey(FirebaseAuth.instance.currentUser!.email)
                      ? splitMap[FirebaseAuth.instance.currentUser!.email]
                          ['amount']!
                      : 0) as num) *
                  -1;
              String paidByEmail = snapshots.data!.docs[index]['paidByEmail'];
              if (paidByEmail == FirebaseAuth.instance.currentUser!.email) {
                amountLent = totalAmount + amountLent;
              }

              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            imageURL: snapshots.data!.docs[index]
                                ['addedByImageUrl'],
                            radius: 12,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${snapshots.data!.docs[index]['addedByUsername']} ${action == TransactionAction.add ? 'added' : 'deleted'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TransactionTile(
                  id: id,
                  status: TransactionStatus.completed,
                  type: type,
                  paidByImageUrl: paidByImageUrl,
                  paidByEmail: snapshots.data!.docs[index]['paidByEmail'],
                  paidByUsername: snapshots.data!.docs[index]['paidByUsername'],
                  description: snapshots.data!.docs[index]['description'],
                  amount: totalAmount.toInt(),
                  amountLent: amountLent.toInt(),
                  timestamp: timestamp,
                  splitMap: splitMap,
                ),
              ]);
            },
          );
        },
      ),
    );
  }
}
