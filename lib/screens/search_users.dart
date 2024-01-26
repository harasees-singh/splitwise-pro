import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/models/user_from_firestore.dart';
import 'package:splitwise_pro/widgets/user_avatar.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({Key? key, required this.onAddNewUser})
      : super(key: key);

  final void Function(UserFromFireStore) onAddNewUser;

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String suggestion = '';
  late Iterable<Widget> _lastOptions = <Widget>[];
  String? _searchingWithQuery;
  List<UserFromFireStore> _fetchedUsers = [];

  void _setUsers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userSnapshots) {
    _fetchedUsers = userSnapshots
        .map((userSnapshot) => UserFromFireStore.fromSnapshot(userSnapshot))
        .toList();
  }

  Future<List<UserFromFireStore>> fakeAPISearch(String query) async {
    await Future<void>.delayed(
        const Duration(milliseconds: 500)); // Fake 1 second delay.
    if (query == '') {
      return List<UserFromFireStore>.empty();
    }
    return _fetchedUsers.where((UserFromFireStore option) {
      return option.username.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) =>
          SearchBar(
        controller: controller,
        hintText: 'search users to add',
        onTap: () {
          controller.openView();
        },
        onChanged: (_) {
          controller.openView();
        },
        leading: const Icon(Icons.search),
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
      ),
      suggestionsBuilder:
          (BuildContext context, SearchController controller) async {
        final users =
            await FirebaseFirestore.instance.collection('users').get();
        _setUsers(users.docs);
        
        _searchingWithQuery = controller.text;
        final List<UserFromFireStore> options =
            (await fakeAPISearch(_searchingWithQuery!)).toList();
        
        // If another search happened after this one, throw away these options.
        // Use the previous options instead and wait for the newer request to
        // finish.
        if (_searchingWithQuery != controller.text) {
          return _lastOptions;
        }
        
        _lastOptions = List<ListTile>.generate(
          options.length,
          (int index) {
            final String username = options[index].username;
            return ListTile(
              onTap: () {
                widget.onAddNewUser(options[index]);
                setState(() {
                  controller.closeView(null);
                });
                controller.clear();
              },
              leading: UserAvatar(imageURL: options[index].imageUrl),
              title: Text(username),
            );
          },
        );
        return _lastOptions;
      },
    );
  }
}
