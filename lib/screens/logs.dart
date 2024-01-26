import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/util/enums/transaction_action.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/widgets/transaction_tile.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({Key? key, required this.groupId}) : super(key: key);

  final String groupId;
  final String envSuffix = kReleaseMode ? '-prod' : '-dev';

  List<QueryDocumentSnapshot<dynamic>> getTimeSortedLogs(List<QueryDocumentSnapshot<dynamic>> transactionsList) {
    transactionsList.sort((a, b) {
      Timestamp aTimestamp = a['timestamp'];
      Timestamp bTimestamp = b['timestamp'];
      return bTimestamp.compareTo(aTimestamp);
    });
    return transactionsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs'), centerTitle: false,),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('logs$envSuffix')
            .where('groupId', isEqualTo: groupId)
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

          List<QueryDocumentSnapshot<dynamic>> logsList = getTimeSortedLogs(snapshots.data!.docs);

          return ListView.builder(
            itemCount: snapshots.data!.docs.length,
            itemBuilder: (ctx, index) {
              TransactionAction action = TransactionAction.values
                  .byName(logsList[index]['action']);
              TransactionType type = TransactionType.values
                  .byName(logsList[index]['type']);
              String id = logsList[index].id;
              String paidByImageUrl =
                  logsList[index]['paidByImageUrl'];
              Timestamp timestamp = logsList[index]['timestamp'];
              num totalAmount = logsList[index]['amount'];
              Map<String, dynamic> splitMap =
                  logsList[index]['split'];
              num amountLent = ((splitMap
                          .containsKey(FirebaseAuth.instance.currentUser!.email)
                      ? splitMap[FirebaseAuth.instance.currentUser!.email]
                          ['amount']!
                      : 0) as num) *
                  -1;
              String paidByEmail = logsList[index]['paidByEmail'];
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
                            imageURL: logsList[index]
                                ['addedByImageUrl'],
                            radius: 12,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${logsList[index]['addedByUsername']} ${action == TransactionAction.add ? 'added' : 'deleted'}',
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
                  paidByEmail: logsList[index]['paidByEmail'],
                  paidByUsername: logsList[index]['paidByUsername'],
                  description: logsList[index]['description'],
                  amount: totalAmount.toInt(),
                  amountLent: amountLent.toInt(),
                  timestamp: timestamp,
                  splitMap: splitMap,
                  dismissible: false,
                ),
              ]);
            },
          );
        },
      ),
    );
  }
}
