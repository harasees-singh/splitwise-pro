import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';
import 'package:splitwise_pro/util/helper/add_transaction.dart';
import 'package:splitwise_pro/widgets/dropdown.dart';

class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({Key? key, required this.setIndex, required this.groupId, required this.groupName}) : super(key: key);

  final void Function(int) setIndex;
  final String groupId;
  final String groupName;

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  UserFromFireStore? _paymentFromUser;
  UserFromFireStore? _paymentToUser;

  late QuerySnapshot<Map<String, dynamic>> _fetchedUsers;
  late List<UserFromFireStore> _users;
  late Future<dynamic> _fetchUsersFuture;

  String _amount = '';

  bool _isLoading = false;

  void _recordCashPayment() async {
    int? amount = int.tryParse(_amount);
    if (_paymentFromUser!.email == _paymentToUser!.email) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select different users'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid integer amount > 0'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, Map<String, dynamic>> splitDetails = {
      _paymentToUser!.email: {
        'amount': amount,
        'username': _paymentToUser!.username,
        'imageUrl': _paymentToUser!.imageUrl,
      }
    };

    try {
      await addTransactionAndUpdateGraph({
        'amount': amount,
        'description': 'Cash payment to ${_paymentToUser!.username}',
        'addedByEmail': FirebaseAuth.instance.currentUser!.email,
        'addedByUsername': FirebaseAuth.instance.currentUser!.displayName,
        'addedByImageUrl': FirebaseAuth.instance.currentUser!.photoURL,
        'paidByEmail': _paymentFromUser!.email,
        'paidByUsername': _paymentFromUser!.username,
        'paidByImageUrl': _paymentFromUser!.imageUrl,
        'splitEqually': true,
        'split': splitDetails,
        'timestamp': Timestamp.now(),
        'status': TransactionStatus.pending.name,
        'type': TransactionType.payment.name,
        'groupsId': widget.groupId
      });
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
      return;
    }
    setState(() {
      _isLoading = false;
    });

    widget.setIndex(0);
  }

  void onChangeFromUser(UserFromFireStore user) {
    setState(() {
      _paymentFromUser = user;
    });
  }

  void onChangeToUser(UserFromFireStore user) {
    setState(() {
      _paymentToUser = user;
    });
  }

  Future _fetchUsers() async {
    _fetchedUsers = await FirebaseFirestore.instance.collection('users').get();
    _users = _fetchedUsers.docs
        .map((userSnapshot) => UserFromFireStore.fromSnapshot(userSnapshot))
        .toList();

    _users = _users.where((user) => user.isVerified).toList();

    _paymentFromUser = 
        _users.firstWhere(
            (user) => user.email == FirebaseAuth.instance.currentUser!.email);
    _paymentToUser = 
        _users.firstWhere(
            (user) => user.email != FirebaseAuth.instance.currentUser!.email);

    return;
  }

  @override
  void initState() {
    super.initState();
    _fetchUsersFuture = _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName} : Settle Up'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
          future: _fetchUsersFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary),
                        decoration: const InputDecoration(
                          label: Text('Enter amount'),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _amount = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text('from',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                    ),
                    DropDownForFireStoreUsers(
                        users: _users, onChanged: onChangeFromUser, selectedUser: _paymentFromUser)
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text('to',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                    ),
                    DropDownForFireStoreUsers(
                        users: _users, onChanged: onChangeToUser, selectedUser: _paymentToUser),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${_paymentFromUser!.username} paid ₹ ${double.tryParse(_amount) == null ? 0 : _amount} in cash to ${_paymentToUser!.username}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              )),
                          onPressed: _recordCashPayment,
                          child: const Text(
                            'Record cash payment',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
