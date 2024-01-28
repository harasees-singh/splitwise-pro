import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/screens/transaction/add_transaction.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/widgets/summary_card.dart';
import 'package:splitwise_pro/widgets/transaction_tile.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.groupId, required this.groupName}) : super(key: key);

  final String groupId;
  final String groupName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final String envSuffix = kReleaseMode ? '-prod' : '-dev';

  void _setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    
    await fcm.requestPermission();
    await fcm.subscribeToTopic(FirebaseAuth.instance.currentUser!.email!);
  }

  List<QueryDocumentSnapshot<dynamic>> getTimeSortedTransactions(List<QueryDocumentSnapshot<dynamic>> transactionsList) {
    transactionsList.sort((a, b) {
      Timestamp aTimestamp = a['timestamp'];
      Timestamp bTimestamp = b['timestamp'];
      return bTimestamp.compareTo(aTimestamp);
    });
    return transactionsList;
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      _setupPushNotifications();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            '${widget.groupName} : Transactions',
            style: Theme.of(context).textTheme.titleLarge!,
          ),
          actions: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: UserAvatar(imageURL: FirebaseAuth.instance.currentUser!.photoURL,),
          )],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SummaryCard(groupId: widget.groupId,),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('transactions$envSuffix')
                    .where('groupId', isEqualTo: widget.groupId)
                    .snapshots(),
                builder: (ctx, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                      
                  if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          'No expenses yet!',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    );
                  }
                      
                  if (snapshots.hasError) {
                    return Expanded(
                      child: Center(
                        child: Text('Something went wrong!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                    );
                  }

                  final transactionsList = getTimeSortedTransactions(snapshots.data!.docs);

                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (ctx, index) {
                        TransactionStatus status = TransactionStatus.values.byName(transactionsList[index]['status']);
                        TransactionType type = TransactionType.values.byName(transactionsList[index]['type']);
                        String id = transactionsList[index].id;
                        String paidByImageUrl =
                            transactionsList[index]['paidByImageUrl'];
                        Timestamp timestamp =
                            transactionsList[index]['timestamp'];
                        num totalAmount = transactionsList[index]['amount'];
                        Map<String, dynamic> splitMap = transactionsList[index]['split'];
                        num amountLent = ((splitMap.containsKey(
                                    FirebaseAuth.instance.currentUser!.email)
                                ? splitMap[
                                    FirebaseAuth.instance.currentUser!.email]['amount']!
                                : 0) as num) *
                            -1;
                        String paidByEmail =
                            transactionsList[index]['paidByEmail'];
                        if (paidByEmail ==
                            FirebaseAuth.instance.currentUser!.email) {
                          amountLent = totalAmount + amountLent;
                        }
                        
                        return TransactionTile(
                          id: id,
                          status: status,
                          type: type,
                          paidByImageUrl: paidByImageUrl,
                          paidByEmail: transactionsList[index]['paidByEmail'],
                          paidByUsername: transactionsList[index]
                              ['paidByUsername'],
                          description: transactionsList[index]['description'],
                          amount: totalAmount.toInt(),
                          amountLent: amountLent.toInt(),
                          timestamp: timestamp,
                          splitMap: splitMap,
                          dismissible: true,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AddTransactionScreen(groupId: widget.groupId,),
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
