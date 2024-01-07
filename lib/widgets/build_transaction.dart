import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/models/pair.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/transaction_split.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BuildTransaction extends StatefulWidget {
  const BuildTransaction({super.key, required this.users});
  final List<UserFromFireStore> users;

  @override
  State<BuildTransaction> createState() => _BuildTransactionState();
}

class _BuildTransactionState extends State<BuildTransaction> {
  final Map<UserFromFireStore, Pair<bool, String>> _transactionSplit = {};
  late UserFromFireStore _userWhoPaid;
  final _descriptionController = TextEditingController();
  int _numberOfPeopleChecked = 0;
  String _amount = '';
  bool _splitEqually = false;
  bool _isLoading = false;

  void _updateSplit(UserFromFireStore user, String amount) {
    _transactionSplit[user]!.second = amount;
  }

  void _recordCheck(UserFromFireStore user, bool wasChecked) {
    _transactionSplit[user]!.first = wasChecked;
    if (wasChecked) {
      setState(() {
        _numberOfPeopleChecked++;
      });
    } else {
      setState(() {
        _numberOfPeopleChecked--;
      });
    }
  }

  void _recordTransaction() async {
    double? amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount > 0'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a description'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_numberOfPeopleChecked == 0) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one debter'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (!_splitEqually) {
      double total = 0;
      for (UserFromFireStore user in widget.users) {
        if (_transactionSplit[user]!.first == false) {
          continue;
        }
        double? amount = double.tryParse(_transactionSplit[user]!.second);
        if (amount == null || amount <= 0) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Please enter a valid amount for all selected users'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        total += amount;
      }
      if (total != amount) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Total amount for all selected users should be equal to the amount paid'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, double> splitDetails = {
      for (UserFromFireStore user in widget.users)
        if (_transactionSplit[user]!.first)
          user.email: double.tryParse(_transactionSplit[user]!.second) ??
              (amount / _numberOfPeopleChecked)
    };
    // persist data to firestore;
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
      'amount': amount,
      'description': _descriptionController.text,
      'paidBy': _userWhoPaid.email,
      'splitEqually': _splitEqually,
      'split': splitDetails,
      'timestamp': Timestamp.now(),
    });
    } catch(e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }
    setState(() {
      _isLoading = false;
    });

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _userWhoPaid = widget.users.firstWhere(
        (user) => user.email == FirebaseAuth.instance.currentUser!.email);
    for (UserFromFireStore user in widget.users) {
      _transactionSplit[user] = Pair(false, '');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: "Amount paid"),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _amount = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<UserFromFireStore>(
                    items: widget.users
                        .map((user) => DropdownMenuItem(
                              value: user,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  UserAvatar(
                                    imageURL: user.imageUrl,
                                    radius: 12,
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: kIsWeb ? 80 : 110,
                                    child: Text(
                                      user.username,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _userWhoPaid = value!;
                      });
                    },
                    value: _userWhoPaid,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: kIsWeb ? 170 : 200,
                  child: TextField(
                    maxLength: 50,
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Split equally',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      Checkbox(
                        value: _splitEqually,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _splitEqually = value!;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                        tristate: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TransactionSplit(
              users: widget.users,
              updateSplit: _updateSplit,
              isEnabled: !_splitEqually,
              wasChecked: _recordCheck,
              splitEqually: _splitEqually,
            ),
            const SizedBox(height: 20),
            Text(
              '${_userWhoPaid.username} paid ₹ ${double.tryParse(_amount) == null ? 0 : _amount} for $_numberOfPeopleChecked people, ${_splitEqually ? 'split will be ₹ ${_numberOfPeopleChecked == 0 || double.tryParse(_amount) == null ? 0 : double.tryParse(_amount)! / _numberOfPeopleChecked} each' : 'to be split unequally'}',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _isLoading ? const Center(child: CircularProgressIndicator()) :  ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    )),
                onPressed: _recordTransaction,
                child: const Text(
                  'Record transaction',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
