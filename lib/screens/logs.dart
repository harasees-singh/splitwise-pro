import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: Center(child: Text('Coming soon!', style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
    );
  }
}