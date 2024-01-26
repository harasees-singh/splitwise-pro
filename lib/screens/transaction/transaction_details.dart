import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.paidByUsername,
    required this.description,
    required this.amount,
    required this.amountLent,
    required this.paidByEmail,
    required this.paidByImageUrl,
    required this.timestamp,
    required this.id,
    required this.status,
    required this.type,
    required this.splitMap,
  });

  final String paidByEmail;
  final String paidByUsername;
  final String description;
  final String paidByImageUrl;
  final int amount;
  final int amountLent;
  final Timestamp timestamp;
  final String id;
  final TransactionStatus status;
  final TransactionType type;
  final Map<String, dynamic> splitMap;

  @override
  Widget build(BuildContext context) {
    Widget statusIcon;
    switch (status) {
      case TransactionStatus.pending:
        statusIcon = const Icon(
          Icons.pending,
          color: Colors.yellow,
        );
        break;
      case TransactionStatus.completed:
        statusIcon = const Icon(
          Icons.check_box,
          color: Colors.green,
        );
        break;
      case TransactionStatus.error:
        statusIcon = const Icon(
          Icons.error,
          color: Colors.red,
        );
        break;
      default:
        statusIcon = const Icon(
          Icons.pending,
          color: Colors.yellow,
        );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: Container(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        imageURL: paidByImageUrl,
                        radius: 15,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '₹$amount',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'paid by $paidByUsername',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      statusIcon,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'on ${timestamp.toDate().toString().substring(0, 10)}',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 10),
            for (final key in splitMap.keys)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          imageURL: splitMap[key]['imageUrl'],
                          radius: 15,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          splitMap[key]['username'],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '₹${splitMap[key]['amount']}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
