import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/widgets/overview_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('graph').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Text('No data', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong!', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              );
            }
            final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
            if (data.docs.isEmpty) {
              return Center(
                child: Text('No data', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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
            final yourGraph = data.docs.firstWhere((doc) => doc.id == FirebaseAuth.instance.currentUser!.email).data();
            totalYouPaidFor = ((yourGraph['totalMoneyPaid'] ?? 0) as num).toInt();
            yourShare = yourGraph['totalShare'] ?? 0;
            yourGraph.remove('totalMoneyPaid');
            yourGraph.remove('totalShare');
            return Column(
              children: [
                OverviewCard(title: 'Global spending', value: globalSpending.toString()),
                OverviewCard(title: 'Total you paid for', value: totalYouPaidFor.toString()),
                OverviewCard(title: 'Your share', value: yourShare.toString()),
              ],
            );
          },
        ),
      ),
    );
  }
}