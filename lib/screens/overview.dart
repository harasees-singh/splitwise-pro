import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/widgets/overview_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({Key? key, required this.groupId}) : super(key: key);

  final String groupId;
  @override
  Widget build(BuildContext context) {
    String envSuffix = kReleaseMode ? '-prod' : '-dev';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
                  .collection('graph$envSuffix')
                  .doc(groupId)
                  .collection('decoy')
                  .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No data',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong!',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            );
          }
          final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
          if (data.docs.isEmpty) {
            return Center(
              child: Text('No data',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
            );
          }
          // total spending, total you paid for, your share
          int globalSpending = 0;
          int totalYouPaidFor = 0;
          int yourShare = 0;
          for (final doc in data.docs) {
            final graph = doc.data();
            if (graph.containsKey('totalMoneyPaid')) {
              globalSpending += (graph['totalMoneyPaid'] as num).toInt();
            }
          }
          Map<String, dynamic>? yourGraph;
          if (data.docs.indexWhere((doc) =>
                  doc.id == FirebaseAuth.instance.currentUser!.email) !=
              -1) {
            yourGraph = data.docs
                .firstWhere(
                    (doc) => doc.id == FirebaseAuth.instance.currentUser!.email)
                .data();

            totalYouPaidFor = ((yourGraph.containsKey('totalMoneyPaid')
                    ? yourGraph['totalMoneyPaid']
                    : 0) as num)
                .toInt();
            yourShare = ((yourGraph.containsKey('totalShare')
                    ? yourGraph['totalShare']
                    : 0) as num)
                .toInt();
            if (yourGraph.containsKey('totalMoneyPaid')) {
              yourGraph.remove('totalMoneyPaid');
            }
            if (yourGraph.containsKey('totalShare')) {
              yourGraph.remove('totalShare');
            }
          }

          return Container(
            margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OverviewCard(
                    title: 'Global spending', value: globalSpending.toString()),
                OverviewCard(
                    title: 'Total you paid for',
                    value: totalYouPaidFor.toString()),
                OverviewCard(title: 'Your share', value: yourShare.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
