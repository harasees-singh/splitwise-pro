import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/screens/transaction/transaction_details.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/util/helper/delete_transaction.dart';
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
      required this.id,
      required this.status,
      required this.type,
      required this.splitMap,
      required this.dismissible});

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
  final bool dismissible;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  bool dismissed = false;
  // int id = -1;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget = widget.type == TransactionType.expense
        ? UserAvatar(
            imageURL: widget.paidByImageUrl,
          )
        : const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.money,
              color: Colors.green,
              size: 40,
            ));
    if (widget.status == TransactionStatus.pending) {
      leadingWidget = const Padding(
          padding: EdgeInsets.all(2), child: CircularProgressIndicator());
    }
    if (widget.status == TransactionStatus.error) {
      leadingWidget = const Icon(
        Icons.error,
        color: Colors.red,
        size: 40,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return TransactionDetailsScreen(
            paidByUsername: widget.paidByUsername,
            description: widget.description,
            amount: widget.amount,
            amountLent: widget.amountLent,
            paidByEmail: widget.paidByEmail,
            paidByImageUrl: widget.paidByImageUrl,
            timestamp: widget.timestamp,
            id: widget.id,
            status: widget.status,
            type: widget.type,
            splitMap: widget.splitMap,
          );
        }));
      },
      child: Dismissible(
        dragStartBehavior: DragStartBehavior.start,
        direction: widget.status == TransactionStatus.completed && widget.dismissible
            ? DismissDirection.horizontal
            : DismissDirection.none,
        movementDuration: const Duration(milliseconds: 300),
        confirmDismiss: (direction) async {
          return await showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text('Delete Transaction',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                  content: Text(
                      'Are you sure you want to delete this transaction?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: const Text('Delete')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: const Text('Cancel')),
                  ],
                );
              });
        },
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
            progress = dismissUpdateDetails.progress;
          });
        },
        onDismissed: (dismissDirection) async {
          try {
            await deleteTransactionAndUpdateGraph(widget.id);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
        key: ValueKey(widget.id),
        child: Card(
          margin: const EdgeInsets.all(0),
          elevation: 0,
          child: ListTile(
            leading: leadingWidget,
            title: Text(
              widget.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.paidByUsername,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                Text(
                  widget.timestamp.toDate().toString().substring(0, 10),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 8),
                ),
              ],
            ),
            trailing: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: widget.type == TransactionType.expense
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.type == TransactionType.expense
                      ? Text(
                          widget.amountLent.toString()[0] == '-'
                              ? '₹${widget.amountLent.toString().substring(1)}'
                              : '₹${widget.amountLent.toString()}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: widget.amountLent > 0
                                      ? const Color.fromARGB(255, 143, 211, 145)
                                      : (widget.amountLent.toDouble() == 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : const Color.fromARGB(
                                              255, 219, 121, 114))),
                        )
                      : const SizedBox.shrink(),
                  Text(
                    '₹${widget.amount}',
                    style: widget.type == TransactionType.expense
                        ? Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.secondary)
                        : Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
