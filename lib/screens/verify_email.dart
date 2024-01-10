import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/screens/home.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  Timer? _timer;

  Future sendVerificationEmail() async {
    try {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .set({
        'verified': true,
      }, SetOptions(merge: true));
      _timer?.cancel();
    }

    if (context.mounted) {
      setState(() {
        _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!_isEmailVerified) {
      sendVerificationEmail();
    }

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _isEmailVerified
      ? const HomeScreen()
      : Scaffold(
          appBar: AppBar(
              title: Text(
                "Please verify your email",
                style: Theme.of(context).textTheme.titleLarge!,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ]),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "A verification email has been sent to ${FirebaseAuth.instance.currentUser!.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        );
}
