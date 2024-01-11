import 'package:flutter/material.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DropDownForFireStoreUsers extends StatelessWidget {
  const DropDownForFireStoreUsers(
      {Key? key, required this.users, required this.onChanged, required this.selectedUser})
      : super(key: key);

  final List<UserFromFireStore> users;
  final void Function(UserFromFireStore) onChanged;
  final UserFromFireStore? selectedUser;

  // @override
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<UserFromFireStore>(
        items: users
            .map(
              (user) => DropdownMenuItem(
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
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          onChanged(value!);
        },
        value: selectedUser,
      ),
    );
  }
}
