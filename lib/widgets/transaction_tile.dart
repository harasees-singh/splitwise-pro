import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class TransactionTile extends StatefulWidget {
  const TransactionTile(
      {super.key,
      required this.paidByUsername,
      required this.description,
      required this.amount,
      required this.amountLent,
      required this.paidByEmail,
      required this.paidByImageUrl,
      required this.timestamp,
      required this.id});

  final String paidByEmail;
  final String paidByUsername;
  final String description;
  final String paidByImageUrl;
  final num amount;
  final num amountLent;
  final Timestamp timestamp;
  final String id;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  bool dismissed = false;
  // int id = -1;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      dragStartBehavior: DragStartBehavior.down,
      movementDuration: const Duration(milliseconds: 500),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            progress > 0.9
                ? const SizedBox(
                    width: 0,
                  )
                : Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                    size: 25,
                  ),
            progress > 0.9
                ? const SizedBox(
                    width: 0,
                  )
                : Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                    size: 25,
                  ),
          ],
        ),
      ),
      dismissThresholds: Map.fromEntries(
        [
          DismissDirection.startToEnd,
          DismissDirection.endToStart,
        ].map((direction) => MapEntry(direction, 0.4)),
      ),
      onUpdate: (dismissUpdateDetails) {
        if (dismissUpdateDetails.reached &&
            dismissUpdateDetails.previousReached == false) {
          HapticFeedback.lightImpact();
        }
        setState(() {
          dismissed = dismissUpdateDetails.reached;
          // id = index;
          progress = dismissUpdateDetails.progress;
        });
      },
      onDismissed: (dismissDirection) async {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(widget.id)
            .delete();
      },
      key: ValueKey(widget.id),
      child: ListTile(
        leading: UserAvatar(
          imageURL: widget.paidByImageUrl,
        ),
        title: Text(
          widget.paidByUsername,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            Text(
              widget.timestamp.toDate().toString().substring(0, 10),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.secondary, fontSize: 8),
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
                widget.amountLent.toString()[0] == '-'
                    ? '₹${widget.amountLent.toStringAsFixed(1).toString().substring(1)}'
                    : '₹${widget.amountLent.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: widget.amountLent > 0
                        ? const Color.fromARGB(255, 143, 211, 145)
                        : (widget.amountLent.toDouble() == 0
                            ? Theme.of(context).colorScheme.secondary
                            : const Color.fromARGB(255, 219, 121, 114))),
              ),
              Text(
                '₹${widget.amount.toDouble()}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
