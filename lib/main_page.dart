import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/screens/auth.dart';
import 'package:splitwise_pro/screens/verify_email.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool _releaseLock = false;

  late Widget authScreen;
  late Widget verifyEmailScreen;

  void _releaseLockPostSuccessfulSignUp() {
    setState(() {
      _releaseLock = true;
    });
  }

  @override
  void initState() {
    super.initState();
    authScreen = AuthScreen(releaseLockPostSuccessfulSignUp: _releaseLockPostSuccessfulSignUp);
    verifyEmailScreen = const VerifyEmailScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && _releaseLock) {
            return verifyEmailScreen;
          }
          return authScreen;
        },
      ),
    );
  }
}
