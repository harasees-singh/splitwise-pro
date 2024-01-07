import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserSplit extends StatefulWidget {
  const UserSplit(
      {super.key,
      required this.isEnabled,
      required this.user,
      required this.updateSplit,
      required this.wasChecked,
      required this.splitEqually});

  final bool isEnabled;
  final bool splitEqually;
  final UserFromFireStore user;
  final void Function(UserFromFireStore, String) updateSplit;
  final void Function(UserFromFireStore, bool) wasChecked;

  @override
  State<UserSplit> createState() => _UserSplitState();
}

class _UserSplitState extends State<UserSplit> {
  bool _isChecked = false;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.splitEqually) {
      setState(() {
        _amountController.text = '';
      });
    }
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  widget.wasChecked(widget.user, value!);
                  if (value == false) {
                    widget.updateSplit(widget.user, '');
                    setState(() {
                      _amountController.text = '';
                    });
                  }
                  setState(() {
                    _isChecked = value;
                  });
                },
              ),
              UserAvatar(
                imageURL: widget.user.imageUrl,
              ),
              const SizedBox(width: 10),
              Text(
                widget.user.username,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(
          width: kIsWeb ? 100 : 120,
          child: TextField(
            controller: _amountController,
            enabled: _isChecked && widget.isEnabled,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount owed',
                labelStyle: TextStyle(fontSize: 14)),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.updateSplit(
                widget.user,
                value,
              );
            },
          ),
        ),
      ],
    );
  }
}
