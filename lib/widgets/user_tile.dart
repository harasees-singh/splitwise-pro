import 'package:flutter/material.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.onDelete});
  final void Function(UserFromFireStore user) onDelete;
  final UserFromFireStore user;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(imageURL: user.imageUrl),
      title: Text(user.username, style: Theme.of(context).textTheme.bodyLarge),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          onDelete(user);
        },
      ),
    );
  }
}
