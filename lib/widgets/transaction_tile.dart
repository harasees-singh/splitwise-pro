import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile(
      {super.key,
      required this.paidByUsername,
      required this.description,
      required this.amount,
      required this.amountLent,
      required this.paidByEmail,
      required this.paidByImageUrl,
      required this.timestamp});

  final String paidByEmail;
  final String paidByUsername;
  final String description;
  final String paidByImageUrl;
  final num amount;
  final num amountLent;
  final Timestamp timestamp;
  // +ve means lent, -ve means owed

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        imageURL: paidByImageUrl,
      ),
      title: Text(
        paidByUsername,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          Text(
            timestamp.toDate().toString().substring(0, 10),
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.secondary, fontSize: 8),
          ),
        ],
      ),
      trailing: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountLent.toString()[0] == '-'
                  ? amountLent.toStringAsFixed(1).toString().substring(1)
                  : amountLent.toStringAsFixed(1).toString(),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: amountLent > 0
                      ? const Color.fromARGB(255, 143, 211, 145)
                      : (amountLent.toDouble() == 0
                          ? Theme.of(context).colorScheme.secondary
                          : const Color.fromARGB(255, 219, 121, 114))),
            ),
            Text(
              amount.toDouble().toString(),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
