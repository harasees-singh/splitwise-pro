import 'package:flutter/widgets.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/user_split.dart';

class TransactionSplit extends StatelessWidget {
  const TransactionSplit(
      {super.key,
      required this.users,
      required this.updateSplit,
      required this.isEnabled,
      required this.wasChecked,
      required this.splitEqually});

  final List<UserFromFireStore> users;
  final void Function(UserFromFireStore, String) updateSplit;
  final void Function(UserFromFireStore, bool) wasChecked;
  final bool splitEqually;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (UserFromFireStore user in users)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: UserSplit(
              isEnabled: isEnabled,
              user: user,
              updateSplit: updateSplit,
              wasChecked: wasChecked,
              splitEqually: splitEqually,
            ),
          ),
      ],
    );
  }
}
