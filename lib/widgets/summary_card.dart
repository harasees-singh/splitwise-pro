import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  Widget getFormattedDebt(num debt) {
    final debtInt = debt.toInt();
    String debtString = debtInt.toString();
    if (debtString.startsWith('-')) {
      debtString = debtString.substring(1);
      return Text(
        '₹$debtString',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: const Color.fromARGB(255, 235, 128, 121)),
      );
    }
    return Text(
      '₹$debtString',
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(color: const Color.fromARGB(255, 144, 238, 144)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('graph')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshots.hasData) {
            return Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Text(
                'You are all settled up!',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
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
          final data = snapshots.data as DocumentSnapshot<Map<String, dynamic>>;
          Map<String, dynamic>? debtGraph = data.data();
          if (debtGraph?.containsKey('totalMoneyPaid') ?? false) {
            debtGraph!.remove('totalMoneyPaid');
          }
          if (debtGraph?.containsKey('totalShare') ?? false) {
            debtGraph!.remove('totalShare');
          }
          if (debtGraph == null || debtGraph.isEmpty) {
            return Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'You are all settled up!',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            );
          }

          num totalMoneyLent = 0;
          for (final entry in debtGraph.entries) {
            totalMoneyLent += entry.value['debt'];
          }

          return Column(
            children: [
              for (final entry in debtGraph.entries)
                if (entry.key !=
                        (FirebaseAuth.instance.currentUser!.email)!
                            .replaceAll(r'.', '') &&
                    entry.value['debt'] != 0)
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: UserAvatar(
                              imageURL: entry.value['imageUrl'], radius: 10),
                          title: Text(entry.value['username'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary)),
                          trailing: getFormattedDebt(entry.value['debt']),
                        ),
                      ),
                    ],
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (totalMoneyLent != 0)
                    Text(
                      'You ${totalMoneyLent < 0 ? 'owe' : 'are owed'} ',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  if (totalMoneyLent != 0) getFormattedDebt(totalMoneyLent),
                  if (totalMoneyLent != 0)
                    Text(
                      ' in total',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  if (totalMoneyLent == 0)
                    Text(
                      'You are all settled up!',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
