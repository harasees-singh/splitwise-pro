import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(
              'Splitwise Pro',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ]),
        body: const Center(
          child: Text('Splitwise Pro'),
        ),
      );
}
