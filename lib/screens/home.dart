import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/screens/add_transaction.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/widgets/summary_card.dart';
import 'package:splitwise_pro/widgets/transaction_tile.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void logout () {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        content: Text('We are sorry to see you go :(', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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
              onPressed: logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const SummaryCard(),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .orderBy('timestamp', descending: true)
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
                      
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (ctx, index) {
                        TransactionStatus status = TransactionStatus.values.byName(snapshots.data!.docs[index]['status']);
                        TransactionType type = TransactionType.values.byName(snapshots.data!.docs[index]['type']);
                        String id = snapshots.data!.docs[index].id;
                        String paidByImageUrl =
                            snapshots.data!.docs[index]['paidByImageUrl'];
                        Timestamp timestamp =
                            snapshots.data!.docs[index]['timestamp'];
                        num totalAmount = snapshots.data!.docs[index]['amount'];
                        Map<String, dynamic> splitMap = snapshots.data!.docs[index]['split'];
                        num amountLent = ((splitMap.containsKey(
                                    FirebaseAuth.instance.currentUser!.email)
                                ? splitMap[
                                    FirebaseAuth.instance.currentUser!.email]['amount']!
                                : 0) as num) *
                            -1;
                        String paidByEmail =
                            snapshots.data!.docs[index]['paidByEmail'];
                        if (paidByEmail ==
                            FirebaseAuth.instance.currentUser!.email) {
                          amountLent = totalAmount + amountLent;
                        }
                        
                        return TransactionTile(
                          id: id,
                          status: status,
                          type: type,
                          paidByImageUrl: paidByImageUrl,
                          paidByEmail: snapshots.data!.docs[index]['paidByEmail'],
                          paidByUsername: snapshots.data!.docs[index]
                              ['paidByUsername'],
                          description: snapshots.data!.docs[index]['description'],
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
